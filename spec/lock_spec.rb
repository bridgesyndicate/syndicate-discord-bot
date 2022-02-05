load 'spec_helper.rb'
require 'integer'
require 'scrims'

RSpec.describe '#lock' do
  before(:each) do
    rom = Scrims::Storage.new.rom
    @lock_repo = Scrims::Locks.new(rom)
  end

  describe 'when the local target is a player' do
    let(:discord_id_1) { rand(2**32) }

    describe 'when the player is not locked' do
      describe 'when the lock status is checked' do
        it 'the player is not locked' do
          expect(@lock_repo.locked?(discord_id_1)).to be false
        end
        it 'the player can be locked for thirty minutes' do
          expect(@lock_repo.lock(discord_id_1, 30.minutes).class).to be Integer
        end
        it 'the player can be locked for one minute' do
          expect(@lock_repo.lock(discord_id_1, 1.minutes).class).to be Integer
        end
      end
    end

    describe 'when the player is locked for n minutes' do
      let(:random_minutes) { rand(30) + 1 }
      before(:each) do
        @lock_repo.lock(discord_id_1, random_minutes.minutes)
      end
      describe 'when the lock status is checked' do
        it 'the player is locked' do
          expect(@lock_repo.locked?(discord_id_1)).to be true
        end
        it 'the player cannot be locked' do
          expect{
            @lock_repo.lock(discord_id_1, 1.minutes)
          }.to raise_error Scrims::DoubleLockError
        end
        it 'can be unlocked' do
          @lock_repo.unlock(discord_id_1)
          expect(@lock_repo.locks.where(discord_id: discord_id_1)
                   .count).to eq 0
        end
      end
      describe 'when n minutes has elapsed' do
        it 'the player is not locked' do
          Timecop.freeze(random_minutes.minutes) do
            expect(@lock_repo.locked?(discord_id_1)).to be false
          end
        end
      end
    end
  end
end
