require 'spec_helper'
require 'scrims'

RSpec.describe '#list' do
  let(:discord_id_1) { rand(2**32).to_s }
  let(:discord_id_2) { rand(2**32).to_s }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invite.new(rom)
    @invites.discord_resolver = MockDiscordResolver.new
    @list = Scrims::ListParty.new(rom)
  end

  describe 'when player is not in a party' do
    it "raises an empty party exception" do
      expect {
        @list.list(discord_id_1)
      }.to raise_error Scrims::ListParty::EmptyPartyError
    end
  end

  describe 'when there are n members in a party' do
    before(:each) do
      @party = []
      @party.push(discord_id_1.to_s)
      @party_size = rand(3) + 1
      @party_size.times do
        random_discord_id = rand(2**32).to_s
        @party.push(random_discord_id.to_s)
        @invites.accept(discord_id_1, random_discord_id)
      end
    end
    it 'lists all n of them' do
      expect(@list.list(discord_id_1) ).to eq @party
    end
  end
end
