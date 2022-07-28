require 'spec_helper'
require 'scrims'
require 'timecop'
require_relative 'shared/queued_players'

RSpec.describe '#ranked' do

  before(:each) do
    rom = Scrims::Storage.new.rom
    @queue = Scrims::Queue.new(rom)
  end

  describe 'basic match making' do
    include_context 'queued players'
    let(:now) { Time.now.to_i }

    describe 'with one player queued' do
      it 'keeps the player queued' do
        @queue.queue_player(p1)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 1
      end
    end
    describe 'with one player queued' do
      it 'unqueues the player' do
        @queue.queue_player(p1)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 1
        @queue.dequeue_player(p1[:discord_id])
        expect(@queue.size).to eq 0
      end
    end
    describe 'with two players who are elo-matchable queued' do
      it 'keeps the player queued' do
        @queue.queue_player(p1)
        @queue.queue_player(p4)
        expect(@queue.process_queue).to be_a Scrims::Match
        expect(@queue.size).to eq 0
      end
    end
    describe 'with two players who are not elo-matchable queued' do
      it 'keeps the player queued' do
        @queue.queue_player(p1)
        @queue.queue_player(p2)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 2
      end
    end
    describe 'with two players past MAX_QUEUE_TIME' do
      it 'creates a match after MAX_QUEUE_TIME seconds' do
        @queue.queue_player(p1)
        @queue.queue_player(p2)
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
        @queue.queue_player(p1)
        @queue.queue_player(p2)
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
