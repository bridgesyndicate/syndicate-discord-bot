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
    rom = Scrims::Storage.rom
    @party_adapter = Scrims::Party.new(rom)
  end

  describe 'party' do
    describe 'does not exist' do
      it 'returns false' do
        expect(@party_adapter.by_party_uuid(party_uuid).size).to eq 0
      end
      describe 'does exist' do
        before(:each) { @party_adapter.create(party) }
        it 'returns true' do
          expect(@party_adapter.by_party_uuid(party_uuid).size).to eq 1
        end
      end
    end
  end
end
