require 'spec_helper'
require 'scrims'
require 'timecop'
require 'mock_elo_resolver'
require_relative 'shared/queued_players'

RSpec.describe '#ranked' do

  before(:each) do
    @rom = Scrims::Storage.new.rom
    @queue = Scrims::Queue.new(@rom)
    @queue.elo_resolver = MockEloResolver.new
    @lock_repo = Scrims::Locks.new(@rom)
  end

  describe 'elo resolver' do
    it 'accepts an elo resolver' do
      expect(@queue.elo_resolver.class).to eq MockEloResolver
    end
  end

  describe 'players' do
    include_context 'queued players'
    let(:now) { Time.now.to_i }

    describe 'with one player queued' do
      it 'keeps the player queued' do
        @queue.queue_player(player_with_600_elo)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 1
      end

      it 'locks the player' do
        @queue.queue_player(player_with_600_elo)
        expect(@lock_repo
          .locked?(player_with_600_elo[:discord_id])
        ).to be true
      end

      it 'throws a locked player exception if the player is queued again' do
        @queue.queue_player(player_with_600_elo)
        expect{
          @queue.queue_player(player_with_600_elo)
        }.to raise_error Scrims::Queue::LockedPlayerError
      end

      it 'throws an already queued exception if the player is queued again after they are unlocked' do
        Timecop.freeze(30.minutes) do
          @queue.queue_player(player_with_600_elo)
          expect{
            @queue.queue_player(player_with_600_elo)
          }.to raise_error Scrims::Queue::LockedPlayerError
        end
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

    describe 'with one party queued' do
      it 'unqueues the party' do
        @queue.queue_player(player_with_600_elo)
        expect(@queue.process_queue).to eq nil
        expect(@queue.size).to eq 1
        @queue.dequeue_player(player_with_600_elo[:discord_id])
        expect(@queue.size).to eq 0
      end
    end
    describe 'with two players who are elo-matchable queued' do
      it 'makes a match' do
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

  describe 'parties' do
    let(:now) { Time.now.to_i }
    let(:discord_id_1) { rand(2**32).to_s }
    let(:discord_id_2) { rand(2**32).to_s }
    let(:discord_id_3) { rand(2**32).to_s }
    let(:discord_id_4) { rand(2**32).to_s }
    let(:party1) { { party_id: @pid } }
    let(:party2) { { party_id: @pid2 } }
    before(:each) do
      @invites = Scrims::Invite.new(@rom)
      @invites.discord_resolver = MockDiscordResolver.new
      @pid = @invites.accept(discord_id_1, discord_id_2)
      @pid2 = @invites.accept(discord_id_3, discord_id_4)
    end

    describe 'with one party of size=2 queued' do
      it 'keeps the party queued' do
        @queue.queue_party(party1)
        expect(@queue.process_queue(party_size=2)).to eq nil
        expect(@queue.size(party_size=2)).to eq 1
      end

      it 'locks the party' do
        @queue.queue_party(party1)
        discord_id_list = [discord_id_1, discord_id_2]
        discord_id_list.each do |discord_id|
          expect(@lock_repo.locked?(discord_id)). to be true
        end
      end

      it 'throws a locked player exception if the party is queued again' do
        @queue.queue_party(party1)
        expect{
          @queue.queue_party(party1)
        }.to raise_error Scrims::Queue::LockedPlayerError
      end

      it 'throws an already queued exception if the party is queued again when they are no longer locked' do
        @queue.queue_party(party1)
        Timecop.freeze(30.minutes) do
          expect{
            @queue.queue_party(party1)
          }.to raise_error Scrims::Queue::AlreadyQueuedError
        end
      end
    end

    describe 'elo adding' do

      it 'it uses STARTING_ELO when the players in a party have no elo' do
        @queue.queue_party(party1)
        expect(@queue
          .queue
          .discord_user_queue
          .to_a
          .first[:elo]).to eq STARTING_ELO
      end

      it 'computes the party\'s average elo when all have available elo' do
        @queue.elo_resolver.elo_map = { discord_id_1 => 200,
                                        discord_id_2 => 1000
                                      }
        @queue.queue_party(party1)
        expect(@queue
          .queue
          .discord_user_queue
          .to_a
          .first[:elo]).to eq 600
      end

      it 'computes the party\'s average elo when one has available elo' do
        @queue.elo_resolver.elo_map = { discord_id_2 => 2000 }
        @queue.queue_party(party1)
        expect(@queue
          .queue
          .discord_user_queue
          .to_a
          .first[:elo]).to eq 1500
      end
    end

    describe 'with one party queued' do
      it 'unqueues the party' do
        @queue.queue_party(party1)
        expect(@queue.process_queue(party_size=2)).to eq nil
        expect(@queue.size(party_size=2)).to eq 1
        @queue.dequeue_party(party1[:party_id])
        expect(@queue.size(party_size=2)).to eq 0
      end
    end
    describe 'with two parties who are elo-matchable queued' do
      it 'determines if a player is queued with a party' do
        @queue.queue_party(party1)
        @queue.queue_party(party2)
        expect([
                discord_id_1,
                discord_id_2,
                discord_id_3,
                discord_id_4]
                 .map{ |discord_id|
                 @queue.member_repo.discord_id_in_party?(discord_id) }
                 .uniq
               ).to eq Array.new.push(true)
        not_in_party = rand(2**32).to_s
        expect(@queue.member_repo.discord_id_in_party?(not_in_party))
          .to eq false
      end
      it 'makes a match' do
        @queue.queue_party(party1)
        @queue.queue_party(party2)
        expect(@queue.process_queue(party_size=2)).to be_a Scrims::Match
        expect(@queue.size(party_size=2)).to eq 0
      end
    end
    describe 'with two parties that are not elo-matchable queued' do
      it 'keeps the parties queued' do
        @queue.elo_resolver.elo_map = { discord_id_3 => 500, discord_id_4 => 400 }
        @queue.queue_party(party1)
        @queue.queue_party(party2)
        expect(@queue.process_queue(party_size=2)).to eq nil
        expect(@queue.size(party_size=2)).to eq 2
      end
    end
    describe 'with two parties past MAX_QUEUE_TIME' do
      it 'creates a match after MAX_QUEUE_TIME seconds' do
        @queue.elo_resolver.elo_map = { discord_id_3 => 500, discord_id_4 => 400 }
        @queue.queue_party(party1)
        @queue.queue_party(party2)
        Timecop.freeze(0) do
          expect(@queue.process_queue(party_size=2)).to eq nil
          expect(@queue.size(party_size=2)).to eq 2
        end
        Timecop.freeze(Scrims::MAX_QUEUE_TIME) do
          expect(@queue.process_queue(party_size=2).class).to eq Scrims::Match
          expect(@queue.size(party_size=2)).to eq 0
        end
      end
    end
    describe 'with three parties queued, and two are elo-matchable' do
      let(:discord_id_5) { rand(2**32).to_s }
      let(:discord_id_6) { rand(2**32).to_s }
      let(:party3) { { party_id: @pid3 } }
      before(:each) do
        @pid3 = @invites.accept(discord_id_5, discord_id_6)
      end

      it 'makes a match' do
        @queue.elo_resolver.elo_map = { discord_id_3 => 1600,
                                        discord_id_4 => 1550
                                      }
        @queue.queue_party(party1)
        @queue.queue_party(party2)
        @queue.queue_party(party3)
        match = @queue.process_queue(party_size=2)
        expect(match.class).to eq Scrims::Match
        expect(@queue.size(party_size=2)).to eq 1
        expect([match.playerA[:party_id],
                match.playerB[:party_id]]).to eq [
                                                party1[:party_id],
                                                party3[:party_id],
                                              ]
      end
    end
  end
end

# #EloRating::k_factor = 10
# match = EloRating::Match.new
# match.add_player(rating: q1.elo)
# match.add_player(rating: q2.elo, winner: true)
# puts match.updated_ratings
