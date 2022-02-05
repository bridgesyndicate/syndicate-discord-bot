load 'spec_helper.rb'
require 'scrims'
require 'schema/game_post'
require 'mock_discord_resolver'
require 'mock_elo_resolver'


RSpec.describe '#duel_accept' do

  let(:discord_id_1) { rand(2**32).to_s }
  let(:discord_id_2) { rand(2**32).to_s }
  let(:discord_id_3) { rand(2**32).to_s }
  let(:discord_id_4) { rand(2**32).to_s }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invite_cmd = Scrims::Invite.new(rom)
    @duel_cmd = Scrims::Duel.new(rom)
    @duel_cmd.discord_resolver = MockDiscordResolver.new
    @duel_cmd.elo_resolver = MockEloResolver.new
    @lock_repo = Scrims::Locks.new(rom)
  end

  describe 'with a valid duel' do

    before(:each) do
      party1 = @invite_cmd.accept(discord_id_1, discord_id_2)
      party2 = @invite_cmd.accept(discord_id_3, discord_id_4)
      @uuid = @duel_cmd.create_duel(discord_id_1, discord_id_3)
    end

    describe 'when the duel has expired' do
      it 'throws an exception' do
        expect {
          Timecop.freeze(1.minutes) do
            @duel_cmd.accept(@uuid)
          end
        }.to raise_error Scrims::Duel::ExpiredDuelError
      end
    end

    describe 'when the uuid is wrong' do
      before(:each) do
        @uuid = SecureRandom.uuid
      end

      it 'throws an exception' do
        expect {
          @duel_cmd.accept(@uuid)
        }.to raise_error Scrims::Duel::MissingDuelError
      end
    end

    describe 'when one of the players is locked' do
      it 'throws an exception' do
        @lock_repo.lock(discord_id_1, 30.minutes)
        expect {
          @duel_cmd.accept(@uuid)
        }.to raise_error Scrims::Duel::LockedPlayerError
      end
    end

    describe 'when it is accepted' do
      before(:each) do
        @duel_cmd.accept(@uuid)
      end

      it 'locks all the players' do
        4.times do |t|
          expect(@lock_repo.locked?(eval("discord_id_#{t + 1}"))).to be true
        end
      end

      it 'makes valid game JSON' do
        expect(JSON::Validator.validate(GamePostSchema.schema,
                                        @duel_cmd.to_json))
          .to be true
      end

      describe 'when it is accepted again' do
        it 'throws an exception' do
          expect {
            @duel_cmd.accept(@uuid)
          }.to raise_error Scrims::Duel::LockedPlayerError
        end
      end
    end
  end
end

