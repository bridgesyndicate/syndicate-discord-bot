require 'spec_helper'
require 'bot_config'

RSpec.describe '#config' do

  let(:namespace) { :syndicate }
  let(:some_key) { :discord_channel }

  before(:each) do
    config_string = File.read(config_file)
    BotConfig.load(config_string, :buckytour_test)
  end

  describe 'when the config file exists' do
    let(:config_file) { './config.yml' }

    it 'gets values from keys' do
      expect(BotConfig.config.discord_channel.class).to eq Integer
    end

    it 'can be used with || to get defaults' do
      expect(BotConfig.config.missing_thing || 'crap').to eq 'crap'
    end
  end
end
