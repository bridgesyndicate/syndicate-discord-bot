require 'spec_helper'
require 'mock_discord_resolver'
require 'mock_elo_resolver'
require 'scrims'

RSpec.describe '#invite accept' do
  let(:discord_id_1) { rand(2**32).to_s }
  let(:discord_id_2) { rand(2**32).to_s }
  let(:discord_id_3) { rand(2**32).to_s }
  let(:discord_id_4) { rand(2**32).to_s }
  let(:discord_id_5) { rand(2**32).to_s }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invite.new(rom)
    @invites.discord_resolver = MockDiscordResolver.new
    @party_repo = Scrims::Storage::Party.new(rom)
    @member_repo = Scrims::MemberRepo.new(rom)
    @queue = Scrims::Queue.new(rom)
    @queue.elo_resolver = MockEloResolver.new
  end

  describe 'when members are already in a party' do
    describe 'when the invitor is in a party' do
      it 'adds the invitee to the invitor\'s party, so there is one party' do
        other_party = @invites.accept(discord_id_1, discord_id_2)
        party = @invites.accept(discord_id_1, discord_id_3)
        expect(@party_repo.parties.to_a.size).to eq 1
      end
      it 'raises an exception if a member from the existing party is queued' do
        party_id = @invites.accept(discord_id_1, discord_id_2)
        party = @party_repo.by_pk(party_id).first
        party = party.to_h.transform_keys{|key| key == :id ? :party_id : key}
        @queue.queue_party(party)
        expect {
          @invites.accept(discord_id_1, discord_id_3)
        }.to raise_error Scrims::Invite::MemberInQueueError
      end
      it 'raises an exception if the player that is not in a party is queued' do
        other_party = @invites.accept(discord_id_1, discord_id_2)
        player_3 = {discord_id: discord_id_3}
        @queue.queue_player(player_3)
        expect {
          @invites.accept(discord_id_1, discord_id_3)
        }.to raise_error Scrims::Invite::MemberInQueueError
      end
    end
    describe 'when the invitee is in a party' do
      it 'adds the invitor to the invitee\'s party, so there is one party' do
        other_party = @invites.accept(discord_id_1, discord_id_2)
        party = @invites.accept(discord_id_2, discord_id_3)
        expect(@party_repo.parties.to_a.size).to eq 1
      end
    end
    describe 'when the invitee is in a party' do
      it 'adds the invitor to the invitee\'s party, so there is one party' do
        other_party = @invites.accept(discord_id_1, discord_id_2)
        party = @invites.accept(discord_id_3, discord_id_2)
        expect(@party_repo.parties.to_a.size).to eq 1
      end
    end
    describe 'when both are in a party' do
      it 'raises an exception' do
        other_party1 = @invites.accept(discord_id_1, discord_id_2)
        other_party2 = @invites.accept(discord_id_3, discord_id_4)
        expect {
          @invites.accept(discord_id_1, discord_id_3)
        }.to raise_error Scrims::Invite::MembersInDifferentPartiesError
      end
    end
  end

  describe 'when neither member is in a party' do
    describe 'accepting an invite' do
      describe 'non exceptions' do
        before(:each) do
          @party_id = @invites.accept(discord_id_1, discord_id_2)
        end
        it 'creates a party' do
          expect(@party_repo.exists?(@party_id)).to eq true
        end
        it 'creates a party with two members' do
          expect(@party_repo.member_count(@party_id)).to eq 2
        end
      end
      describe 'exceptions' do
        it 'raises an exception if the two members are the same' do
          expect {
            @invites.accept(discord_id_1, discord_id_1)
          }.to raise_error ROM::SQL::UniqueConstraintError
        end
        it 'raises an exception if one of the members is queued' do
          player_1 = {discord_id: discord_id_1}
          @queue.queue_player(player_1)
          expect {
            @invites.accept(discord_id_1, discord_id_2)
          }.to raise_error Scrims::Invite::MemberInQueueError
        end
      end
    end
  end

  describe 'for the default value of 4' do
    describe 'when there are too many members in a party' do
      it 'raises an exception with the default (4)' do
        @invites.accept(discord_id_1, discord_id_2)
        @invites.accept(discord_id_1, discord_id_3)
        @invites.accept(discord_id_1, discord_id_4)
        expect {
          @invites.accept(discord_id_1, discord_id_5)
        }.to raise_error Scrims::Invite::TooManyMembersError
      end
    end
  end

  describe 'for a non-default value (5)' do
    it 'works with 5 when the default is raised' do
      @invites.max_members = 5
      @invites.accept(discord_id_1, discord_id_2)
      @invites.accept(discord_id_1, discord_id_3)
      @invites.accept(discord_id_1, discord_id_4)
      expect(@invites.accept(discord_id_1, discord_id_5)).to be_a Integer
    end
  end
end
