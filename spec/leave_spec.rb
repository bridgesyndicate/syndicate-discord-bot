load 'spec_helper.rb'
require 'scrims'

RSpec.describe '#leave' do
  let(:discord_id_1) { rand(2**32) }
  let(:discord_id_2) { rand(2**32) }
  let(:discord_id_3) { rand(2**32) }
  let(:discord_id_4) { rand(2**32) }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invite.new(rom)
    @leave = Scrims::Leave.new(rom)
    @party_repo = Scrims::PartyRepo.new(rom)
    @member_repo = Scrims::MemberRepo.new(rom)
  end

  describe 'when the player is not in a party' do
    describe 'and leaves' do
      it 'throws an exception' do
        party = @invites.accept(discord_id_1, discord_id_2)
        expect {
          @leave.leave(discord_id_3)
        }.to raise_error Scrims::Leave::MemberNotInParty
      end
    end
  end

  describe 'when there are two members in a party' do
    describe 'and one leaves' do
      before(:each) do
        @party = @invites.accept(discord_id_1, discord_id_2)
        @leave.leave(discord_id_1)
      end
      it 'deletes both members' do
        expect(@party_repo.empty?(@party)).to be true
      end
      it 'deletes the party' do
        expect(@party_repo.exists?(@party)).to eq false
      end
    end
  end

  describe 'when there are three members in a party' do
    describe 'and one leaves' do
      before(:each) do
        @invites.accept(discord_id_1, discord_id_2)
        @party = @invites.accept(discord_id_2, discord_id_3)
        @leave.leave(discord_id_1)
      end
      it 'deletes the member' do
        expect(@party_repo.with_members(@party)
                 .first
                 .members
                 .map { |member| member.discord_id } ).not_to include discord_id_1
      end
      it 'keeps the party with two members' do
        expect(@party_repo.member_count(@party)).to eq 2
      end
    end
  end

  describe 'when there are two parties' do
    before(:each) do
      @party_1 = @invites.accept(discord_id_1, discord_id_2)
      @party_2 = @invites.accept(discord_id_3, discord_id_4)
    end
    it 'there are two parties' do
      expect(@party_repo.parties.to_a.size).to eq 2
    end
    describe 'and one player leaves one of the parties' do
      before(:each) do
        @leave.leave(discord_id_1)
      end
      it 'there is one party' do
        expect(@party_repo.parties.to_a.size).to eq 1
      end
      it 'the single member party is deleted' do
        expect(@party_repo.exists?(@party_1)).to eq false
      end
      it 'the other party is kept' do
        expect(@party_repo.exists?(@party_2)).to eq true
      end
      it 'there are a total of 2 members' do
        expect(@member_repo.members.to_a.size).to eq 2
      end
      it 'they are both in party_2' do
        expect(@party_repo.member_count(@party_2)).to eq 2
      end
    end
  end
end
