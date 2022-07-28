require 'spec_helper'
require 'scrims'

RSpec.describe '#scrims' do
  let(:party) {
    {
      created_at: Time.now
    }
  }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @party_repo = Scrims::Storage::Party.new(rom)
  end

  describe 'party' do
    describe 'does not exist' do
      it 'returns false' do
        expect(@party_repo.exists?(1)).to be false
      end
      describe 'does exist' do
        before(:each) {
          @party = @party_repo.create(party)
        }
        it 'returns true' do
          expect(@party_repo.exists?(@party.id)).to be true
        end
      end
    end
  end
end
