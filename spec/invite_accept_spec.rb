load 'spec_helper.rb'
require 'scrims'

RSpec.describe '#invite accept' do
  let(:discord_id_1) { rand(2**32) }
  let(:discord_id_2) { rand(2**32) }

  before(:each) do
    rom = Scrims::Storage.instance.rom
    @invites = Scrims::Invites.new(rom)
    @party_repo = Scrims::PartyRepo.new(rom)
    @member_repo = Scrims::MemberRepo.new(rom)
  end

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
      it 'raises an exception if one of the two members are already in a party' do
        party = @party_repo.create({
                                     party_uuid: SecureRandom.uuid,
                                     created_at: Time.now.to_i
                                   })
        @member_repo.create({ party_id: party.id, discord_id: discord_id_1 })
        expect {
          @invites.accept(discord_id_1, discord_id_2)
        }.to raise_error ROM::SQL::UniqueConstraintError
      end
    end
  end
end
