load 'spec_helper.rb'
require 'scrims'

RSpec.describe '#scrims' do
  let(:discord_id) { rand(2**32) }
  let(:party_uuid) { SecureRandom.uuid }
  let(:party) {
    {
      party_uuid: party_uuid,
      created_at: Time.now.to_i
    }
  }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @party_repo = Scrims::PartyRepo.new(rom)
  end

  describe 'party' do
    describe 'does not exist' do
      it 'returns false' do
        expect(@party_repo.party_uuid_exists?(party_uuid)).to be false
      end
      describe 'does exist' do
        before(:each) { @party_repo.create(party) }
        it 'returns true' do
          expect(@party_repo.party_uuid_exists?(party_uuid)).to be true
        end
      end
    end
  end
end
