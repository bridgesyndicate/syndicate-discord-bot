require 'spec_helper'
require 'discord_mock'
require 'scrims'
require 'bot_config'
BotConfig.load(File.read('./config.yml'), :syndicate)
require 'syndicate_embeds'

RSpec.describe '#embeds' do

  before(:each) do
    @event = DiscordMock::Event.new
  end

  let(:players) { rand(4) + 1 }
  let(:party) { players.times.map {|t| rand(2**32)} }
  let(:red) { players.times.map {|t| rand(2**32)} }
  let(:blue) { players.times.map {|t| rand(2**32)} }
  let(:error) { nil }

  describe 'party list' do
    before(:each) do
      SyndicateEmbeds::Builder
        .send(:party_list,
              event: @event,
              error: error,
              discord_id_list: party)
    end

    it 'the players are in mentions' do
      party.each do |player|
        expect(@event.channel.messages.first
                 .embed
                 .description.include? ( "<@#{player}>" )
                ).to be true
      end
    end

    it 'begins with the right message' do
      party.each do |player|
        expect(@event.channel.messages.first
                 .embed
                 .description.start_with? ( SyndicateEmbeds.wrap_strong('Your party:') )
                ).to be true
      end
    end

    describe 'with an error' do
      let(:error) { Scrims::ListParty::EmptyPartyError.new}
      let(:party) {nil}
      it 'has the right message' do
        expect(@event.channel.messages.first
                 .embed.description).to match /Your party is empty/
      end

      it 'does not have any formatted mentions' do
        expect(!@event.channel.messages.first
                 .embed
                 .description
                 .match(/\d/)
                ).to be true
      end
    end

  end


  describe 'duel requests' do
    before(:each) do
      discord_id_list = {red: red, blue: blue}
      SyndicateEmbeds::Builder
        .send(:duel_request,
              event: @event,
              error: error,
              discord_id_list: discord_id_list)
    end

    it 'sends a duel request' do
      expect(@event.channel.messages.size).to eq 1
    end

    it 'has the right message' do
      expect(@event.channel
               .messages
               .first.embed.title).to match /You have received a duel request/
    end

    it 'the message is strong' do
      expect(@event.channel
               .messages
               .first.embed.title).to match /^\*\*.*\*\*$/
    end

    it 'has an accept button' do
      expect(@event.channel.messages.first
               .view
               .rows.first.buttons.first
               .attributes[:label]).to eq 'Accept'
    end
  end

  describe 'accept duel request' do
    before(:each) do
      discord_id_list = {red: red, blue: blue}
      SyndicateEmbeds::Builder
        .update(:accept_duel_request,
                event: @event,
                error: error,
                discord_id_list: discord_id_list)
    end

    it 'sends the message' do
      expect(@event.channel.messages.size).to eq 1
    end

    it 'has the right message' do
      expect(@event.channel.messages
               .first.embed.title).to match /You have accepted this duel request/
    end
    describe 'with an error' do
      let(:error) { Scrims::DoubleLockError.new}
      it 'has the right message' do
        expect(@event.channel.messages.first
                 .embed.description).to match /You cannot duel yourself/
      end
    end
  end

  describe 'duel request sent acknowledge' do
    before(:each) do
      discord_id_list = {red: red, blue: blue}
      SyndicateEmbeds::Builder
        .send(:duel_request_sent,
              event: @event,
              error: error,
              discord_id_list: discord_id_list)
    end

    it 'sends the message' do
      expect(@event.channel.messages.size).to eq 1
    end

    describe 'with an error' do
      let(:error) { Scrims::Duel::PartySizesUnequalError.new(3)}

      it 'sends the message' do
        expect(@event.channel.messages.size).to eq 1
      end

      it 'has the right error' do
        expect(@event.channel.messages
                 .first.embed.description).to match /The party sizes are unequal/
      end
    end
  end

  describe 'party invite sent' do
    describe 'with no error' do
      let(:discord_id_list) { rand(2**32).to_s }
      before(:each) do
        SyndicateEmbeds::Builder
          .send(:party_invite_sent,
                event: @event,
                discord_id_list: discord_id_list)
      end

      it 'formats the string into a mention' do
        expect(@event.channel.messages.first
                         .embed
                         .description.include? ( "<@#{discord_id_list}>" )
                        ).to be true
      end
    end

    describe 'with an error' do
      before(:each) do
        SyndicateEmbeds::Builder
          .send(:party_invite_sent,
                event: @event,
                error: :banned_sender)
      end

      it 'notifies of a ban when the error is BannedSender' do
        expect(@event.channel.messages.first
                 .embed
                 .description)
          .to eq SyndicateEmbeds.wrap_strong('You are banned.')
      end
    end
  end
end
