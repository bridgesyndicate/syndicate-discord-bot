require 'spec_helper'
require 'elo_resolver'
require 'mock_elo_resolver'

RSpec.describe '#elo resolver' do
  shared_examples 'correct elo resolution structure' do
    it 'returns a hash' do
      expect(elo_resolver.resolve_elo_from_discord_ids.class).to be Hash
    end

    it 'has elo as a property' do
      expect(
             elo_resolver
               .resolve_elo_from_discord_ids
               .map{ |k, v| v["elo"] }
               .include?(nil))
        .to eq false
    end

    it 'has season_elos as a property' do
      expect(
             elo_resolver
               .resolve_elo_from_discord_ids
               .map{ |k, v| v["elo"] }
               .include?(nil))
        .to eq false
    end

    it 'uses resolves as an array of the right size' do
      expect(
             elo_resolver
               .resolve_elo_from_discord_ids
               .map{ |k, v| v["elo"] }
               .size
             )
        .to eq discord_ids.size
    end

    it 'resolves as integers' do
      expect(
             elo_resolver
               .resolve_elo_from_discord_ids
               .map{ |k, v| v["elo"] }
               .map{ |v| v.class }
               .uniq.first
             )
        .to eq Integer
    end
  end

  describe 'for the EloResolver class' do
    let(:response) { File.read('spec/mocks/syndicate-web-service/user/by-discord-id/post-response-with-no-season-elos.json') }
    let(:elo_resolver) { EloResolver.new }
    let(:discord_ids) { %w/829088868817043467 246107858712788993 327218070827565088 424617772039798794 717098844432760833 484145959287390270/ }

    before(:each) do
      stub_request(:post, "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/user/by-discord-id")
        .to_return(status: 200, body: response, headers: {})
      elo_resolver.discord_ids = discord_ids
    end

    it_behaves_like 'correct elo resolution structure'
  end

  describe 'for the MockEloResolver class without a map' do
    let(:elo_resolver) { MockEloResolver.new }
    let(:discord_ids) { %w/829088868817043467 246107858712788993 327218070827565088 424617772039798794 717098844432760833 484145959287390270/ }

    before(:each) do
      elo_resolver.discord_ids = discord_ids
    end

    it_behaves_like 'correct elo resolution structure'
  end

  describe 'for the MockEloResolver class with a map' do
    let(:elo_resolver) { MockEloResolver.new }
    let(:elo_map) {
      {
        "829088868817043467" => {
          'elo' => 1233,
          'season_elos' => {
            'foo' => 1002
          }
        },
        "246107858712788993" => {
          'elo' => 983,
          'season_elos' => {
            'bar' => 2118,
            'baz12' => 1002
          }
        },
        "32721807082756508" => {
          'season_elos' => {},
          'elo' => 813,
        }
      }
    }

    let(:discord_ids) { %w/829088868817043467 246107858712788993 32721807082756508/ }

    before(:each) do
      elo_resolver.discord_ids = discord_ids
      elo_resolver.elo_map = elo_map
    end

    it_behaves_like 'correct elo resolution structure'

    it 'returns one elo when the map has three' do
      elo_resolver.discord_ids = %w/246107858712788993/
      expect(
             elo_resolver
               .resolve_elo_from_discord_ids.size
             ).to eq 1
    end
  end
end
