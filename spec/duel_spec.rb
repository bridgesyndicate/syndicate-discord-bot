require 'spec_helper'
require 'scrims'
require 'mock_discord_notifier'
require 'mock_discord_resolver'
require 'mock_elo_resolver'

RSpec.describe '#duel' do

  describe 'when the target is in a party' do
    let(:discord_id_1) { rand(2**32).to_s }
    let(:discord_id_2) { rand(2**32).to_s }
    let(:discord_id_3) { rand(2**32).to_s }
    let(:discord_id_4) { rand(2**32).to_s }
    let(:discord_id_5) { rand(2**32).to_s }

    before(:each) {
      rom = Scrims::Storage.new.rom
      @invite_cmd = Scrims::Invite.new(rom)
      @invite_cmd.discord_resolver = MockDiscordResolver.new
      @duel_cmd = Scrims::Duel.new(rom)
      @list = Scrims::ListParty.new(rom)
      @duel_cmd.notifier = MockNotifier.new
      @party_repo = Scrims::Storage::Party.new(rom)
      @queue = Scrims::Queue.new(rom)
      @queue.elo_resolver = MockEloResolver.new
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
        }.to raise_error Scrims::Duel::PartySizesUnequalError
      end
    end

    describe 'when one player is in a party and one is not' do
      before(:each) do
        @invite_cmd.accept(discord_id_1, discord_id_2)
      end

      it 'throws an exception and does not make a duel request' do
        expect {
          @duel_cmd.create_duel(discord_id_1, discord_id_3)
        }.to raise_error Scrims::Duel::PartySizesUnequalError
        expect(@duel_cmd.duel_request.duels.count)
          .to eq 0
      end
    end

    describe 'when neither player is in a party' do

      describe 'when one of the players is queued' do
        before (:each) do
          player_1 = {discord_id: discord_id_1}
          @queue.queue_player(player_1)
        end
        it 'throws an exception' do
          expect {
            @duel_cmd.create_duel(discord_id_1, discord_id_2)
          }.to raise_error Scrims::Duel::MemberInQueueError
        end
      end

      describe 'non exceptions' do
        before (:each) do
          @duel_cmd.create_duel(discord_id_1, discord_id_2)
        end
        it 'creates a duel request' do
          expect(@duel_cmd.duel_request.duels.count)
            .to eq 1
        end
        it 'the duel request participants are a hash' do
          expect(JSON.parse(@duel_cmd.duel_request.duels.first.participants))
            .to be_a Hash
        end
        it 'creates a duel request with two players' do
          expect(JSON.parse(@duel_cmd.duel_request.duels
                              .first
                              .participants)['red'].size).to eq 1
          expect(JSON.parse(@duel_cmd.duel_request.duels
                              .first
                              .participants)['blue'].size).to eq 1
        end
      end
    end

    describe 'when the party sizes are equal' do
      before (:each) do
        @party_id_1 = @invite_cmd.accept(discord_id_1, discord_id_2)
        @party_id_2 = @invite_cmd.accept(discord_id_3, discord_id_4)
      end

      describe 'when one of the parties is queued' do
        before (:each) do
          party_1 = @party_repo.by_pk(@party_id_1).first
          party_1 = party_1.to_h.transform_keys{|key| key == :id ? :party_id : key}
          @queue.queue_party(party_1)
        end

        it 'throws an exception' do
          expect {
            @duel_cmd.create_duel(discord_id_1, discord_id_3)
          }.to raise_error Scrims::Duel::MemberInQueueError
        end
      end

      describe 'non exceptions' do
        before(:each) do
          @duel_cmd.create_duel(discord_id_1, discord_id_3)
        end

        it 'creates a duel request' do
          expect(@duel_cmd.duel_request.duels.count)
            .to eq 1
        end
        it 'the duel request participants are a hash' do
          expect(JSON.parse(@duel_cmd.duel_request.duels.first.participants))
            .to be_a Hash
        end
        it 'creates a duel request with two v. two players' do
          expect(JSON.parse(@duel_cmd.duel_request.duels
                              .first
                              .participants)['red'].size).to eq 2
          expect(JSON.parse(@duel_cmd.duel_request.duels
                              .first
                              .participants)['blue'].size).to eq 2

        end

        describe 'when the duel request has been created' do
          before(:each) do
            @duel_cmd.create_duel(discord_id_1, discord_id_3)
            discord_ids = @list.list(discord_id_3)
            @duel_cmd.notifier.notify(discord_ids)
          end
          it 'notifies the opposing players' do
            expect(@duel_cmd.notifier.receipts.size).to eq 2
          end
        end
      end
    end
  end
end
