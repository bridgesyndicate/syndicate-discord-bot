load 'spec_helper.rb'
require 'scrims'

RSpec.describe '#leave' do
  let(:discord_id_1) { rand(2**32) }
  let(:discord_id_2) { rand(2**32) }
  let(:discord_id_3) { rand(2**32) }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invites.new(rom)
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
        expect(@party_repo.empty?(@party.party_uuid)).to be true
      end
      it 'deletes the party' do
        expect(@party_repo.party_uuid_exists?(@party.party_uuid)).to eq false
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
        expect(@party_repo.members(@party.party_uuid)
                 .members
                 .map { |member| member.discord_id } ).not_to include discord_id_1
      end
      it 'keeps the party with two members' do
        expect(@party_repo.members(@party.party_uuid)
                 .members.size).to eq 2
      end
    end
  end
end
