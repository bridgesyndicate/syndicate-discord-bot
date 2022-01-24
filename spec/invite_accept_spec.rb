load 'spec_helper.rb'
require 'scrims'

RSpec.describe '#invite accept' do
  let(:discord_id_1) { rand(2**32) }
  let(:discord_id_2) { rand(2**32) }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invites.new(rom)
    @party_repo = Scrims::PartyRepo.new(rom)
    @member_repo = Scrims::MemberRepo.new(rom)
  end

  describe 'when members are already in a party' do
    let(:discord_id_3) { rand(2**32) }
    let(:discord_id_4) { rand(2**32) }

    describe 'when the invitor is in a party' do
      it 'adds the invitee to the invitor\'s party, so there is one party' do
        other_party = @invites.accept(discord_id_1, discord_id_2)
        party = @invites.accept(discord_id_1, discord_id_3)
        expect(@party_repo.parties.to_a.size).to eq 1
      end
    end
    describe 'when the invitee is in a party' do
      it 'adds the invitor to the invitee\'s party, so there is one party' do
        other_party = @invites.accept(discord_id_1, discord_id_2)
        party = @invites.accept(discord_id_2, discord_id_3)
        expect(@party_repo.parties.to_a.size).to eq 1
      end
    end
    describe 'when both are in a party' do
      it 'raises an exception' do
        other_party1 = @invites.accept(discord_id_1, discord_id_2)
        other_party2 = @invites.accept(discord_id_3, discord_id_4)
        expect {
          @invites.accept(discord_id_1, discord_id_3)
        }.to raise_error 'Cannot party when both members are in different parties'
      end
    end
  end

  describe 'when neither member is in a party' do
    describe 'accepting an invite' do
      describe 'non exceptions' do
        before(:each) do
          @party = @invites.accept(discord_id_1, discord_id_2)
        end
        it 'creates a party' do
          expect(@party_repo.party_uuid_exists?(@party.party_uuid)).to eq true
        end
        it 'creates a party with two members' do
          expect(@party_repo.member_count(@party.party_uuid)).to eq 2
        end
      end
      describe 'exceptions' do
        it 'raises an exception if the two members are the same' do
          expect {
            @invites.accept(discord_id_1, discord_id_1)
          }.to raise_error ROM::SQL::UniqueConstraintError
        end
      end
    end
  end
end
