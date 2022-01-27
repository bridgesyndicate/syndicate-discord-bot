load 'spec_helper.rb'
require 'scrims'
require 'mock_discord_resolver'
require 'mock_elo_resolver'
require 'schema/game_post'

RSpec.describe '#duel' do

  describe 'when the target is in a party' do
    let(:discord_id_1) { rand(2**32) }
    let(:discord_id_2) { rand(2**32) }
    let(:discord_id_3) { rand(2**32) }
    let(:discord_id_4) { rand(2**32) }
    let(:discord_id_5) { rand(2**32) }

    before(:each) {
      rom = Scrims::Storage.new.rom
      @invite_cmd = Scrims::Invite.new(rom)
      @duel_cmd = Scrims::Duel.new(rom)
      @duel_cmd.discord_resolver = MockDiscordResolver.new
      @duel_cmd.elo_resolver = MockEloResolver.new
    }

    describe 'when the party sizes are not equal' do
      before(:each) {
        @invite_cmd.accept(discord_id_1, discord_id_2)
        @invite_cmd.accept(discord_id_1, discord_id_3)
        @invite_cmd.accept(discord_id_4, discord_id_5)
      }

      it 'throws an exception' do
        expect {
          @duel_cmd.create_duel(discord_id_1, discord_id_4)
        }.to raise_error Scrims::Duel::PartySizesUnequal
      end
    end

    describe 'when the party sizes are equal' do
      before(:each) {
        @invite_cmd.accept(discord_id_1, discord_id_2)
        @invite_cmd.accept(discord_id_3, discord_id_4)
      }

      describe 'when any of the players are locked' do
        it 'throws a locked exception' do          
        end
      end
      describe 'when all of the players are not locked' do
        describe 'when any party member is not verified' do
          it 'throws' do
          end
        end
        describe 'when all players are verified' do
          it 'creates a game' do
            @duel_cmd.create_duel(discord_id_1, discord_id_3)
            expect(JSON::Validator.validate(GamePostSchema.schema, 
                                            @duel_cmd.to_json))
              .to be true
          end
        end
      end
    end
  end
  
  describe 'when the target is not in a party' do
    describe 'when either player is in a party' do
      it 'throws an exception' do
      end
    end
    describe 'when neither player is in a party' do
      describe 'when either of the players are locked' do
        it 'throws a locked exception' do
        end
      end
      describe 'when both of the players are not locked' do
        describe 'when either player is not verified' do
          it 'throws' do
          end
        end
        describe 'when both players are verified' do
          it 'calls syndicate web service' do
          end
        end
      end
    end
  end
end