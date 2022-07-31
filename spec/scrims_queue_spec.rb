require 'spec_helper'
require 'scrims'
require 'timecop'
require 'mock_elo_resolver'
require_relative 'shared/queued_players'

RSpec.describe '#ranked' do

  before(:each) do
    rom = Scrims::Storage.new.rom
    @queue = Scrims::Queue.new(rom)
    @queue.elo_resolver = MockEloResolver.new
  end

  describe 'elo resolver' do
    it 'accepts an elo resolver' do
      expect(@queue.elo_resolver.class).to eq MockEloResolver
    end
  end

  describe 'basic match making' do
    include_context 'queued players'
    let(:now) { Time.now.to_i }

    describe 'with one player queued' do
      it 'keeps the player queued' do
        @queue.queue_player(player_with_600_elo)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 1
      end

      it 'throws an exception if the player is queued again' do
        @queue.queue_player(player_with_600_elo)
        expect{
          @queue.queue_player(player_with_600_elo)
        }.to raise_error Scrims::Queue::AlreadyQueuedError
      end
    end

    describe 'elo adding' do
      include_context 'queued players'

      it 'adds elo when it queues a player without it' do
        @queue.queue_player(player_without_elo)
        expect(@queue
          .queue
          .discord_user_queue
          .to_a
          .first[:elo]).to eq STARTING_ELO
      end

      it 'adds keeps the player\'s elo' do
        @queue.elo_resolver.elo_map = { player_with_600_elo[:discord_id] => 600 }
        @queue.queue_player(player_with_600_elo)
        expect(@queue
          .queue
          .discord_user_queue
          .to_a
          .first[:elo]).to eq 600
      end
    end

    describe 'with one player queued' do
      it 'unqueues the player' do
        @queue.queue_player(player_with_600_elo)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 1
        @queue.dequeue_player(player_with_600_elo[:discord_id])
        expect(@queue.size).to eq 0
      end
    end
    describe 'with two players who are elo-matchable queued' do
      it 'keeps the player queued' do
        @queue.queue_player(player_with_600_elo)
        @queue.queue_player(p4)
        expect(@queue.process_queue).to be_a Scrims::Match
        expect(@queue.size).to eq 0
      end
    end
    describe 'with two players who are not elo-matchable queued' do
      it 'keeps the player queued' do
        @queue.elo_resolver.elo_map = { player_with_600_elo[:discord_id] => 600 }
        @queue.queue_player(player_with_600_elo)
        @queue.queue_player(player_without_elo)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 2
      end
    end
    describe 'with two players past MAX_QUEUE_TIME' do
      it 'creates a match after MAX_QUEUE_TIME seconds' do
        @queue.elo_resolver.elo_map = { player_with_600_elo[:discord_id] => 600 }
        @queue.queue_player(player_with_600_elo)
        @queue.queue_player(player_without_elo)
        Timecop.freeze(0) do
          expect(@queue.process_queue).to eq nil
          expect(@queue.size).to eq 2
        end
        Timecop.freeze(Scrims::MAX_QUEUE_TIME) do
          expect(@queue.process_queue.class).to eq Scrims::Match
          expect(@queue.size).to eq 0
        end
      end
    end
    describe 'with three players queued, and two are elo-matchable' do
      it 'makes a match' do
        @queue.queue_player(player_with_600_elo)
        @queue.queue_player(player_without_elo)
        @queue.queue_player(p3)
        expect(@queue.process_queue.class).to eq Scrims::Match
        expect(@queue.size).to eq 1
      end
    end
  end
end

# #EloRating::k_factor = 10
# match = EloRating::Match.new
# match.add_player(rating: q1.elo)
# match.add_player(rating: q2.elo, winner: true)
# puts match.updated_ratings
