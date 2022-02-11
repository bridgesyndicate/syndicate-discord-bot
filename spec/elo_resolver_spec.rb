require 'spec_helper'
require 'elo_resolver'

RSpec.describe '#elo resolver' do
  describe 'for players without elo' do

    let(:response) { File.read('spec/mocks/syndicate-web-service/user/by-discord-id/post-response-with-nulls.json') }

    before(:each) do
      stub_request(:post, "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/user/by-discord-id")
        .to_return(status: 200, body: response, headers: {})
    end

    it 'uses resolves as the STARTING_ELO' do
      elo_resolver = EloResolver.new
      elo_resolver.discord_ids = %w/829088868817043467 246107858712788993 327218070827565088 424617772039798794 717098844432760833 484145959287390270/
      expect(elo_resolver.resolve_elo_from_discord_ids.class).to be Hash
      expect(
             elo_resolver.resolve_elo_from_discord_ids
               .values
               .include?(nil))
        .to eq false
      expect(elo_resolver.resolve_elo_from_discord_ids
             .values).to eq [STARTING_ELO, 1030, STARTING_ELO, STARTING_ELO, 1991, 1404]
    end
  end
end
