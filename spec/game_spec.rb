load 'spec/spec_helper.rb'
require 'lib/game'

describe '#game model' do
  let(:message_struct) { JSON.parse(game_json, object_class: OpenStruct) }
  let(:game_struct) { message_struct.dynamodb.new_image.game }
  let(:game) { Game.new(game_struct) }
  shared_examples 'base class' do
    describe 'initialize' do
      it 'news' do
        expect(game.class).to eq Game
      end
      it 'provides the uuid' do
        expect(game.uuid).to match UUID_REGEX
      end
    end
  end
  shared_examples 'finished games' do
    it 'gives the right winner names' do
      expect(game.winner_names)
        .to eq "<@246107858712788993>, <@346107858712788994>"
    end
    it 'gives the right winner names and elos' do
      expect(game.winner_names(:with_elo_changes))
        .to eq "<@246107858712788993> (+16), <@346107858712788994> (+15)"
    end
    it 'gives the right loser names' do
      expect(game.loser_names)
        .to eq "<@417766998471213061>, <@517766998471213062>"
    end
    it 'gives the right loser names and elos' do
      expect(game.loser_names(:with_elo_changes))
        .to eq "<@417766998471213061> (-16), <@517766998471213062> (-15)"
    end
  end

  context 'new game' do
    let(:game_json) { File.read('./spec/mocks/new-game-sqs.json') }
    it_behaves_like 'base class'
    it 'has a red team' do
      expect(game.red_team_discord_mentions).to eq "<@417766998471213061>"
    end
    it 'has a blue team' do
      expect(game.blue_team_discord_mentions).to eq "<@240177490906054658>"
    end
  end
  context 'game score' do
    let(:game_json) { File.read('./spec/mocks/game-score-sqs.json') }
    it_behaves_like 'base class'
    it_behaves_like 'finished games'
    it 'has a red team' do
      expect(game.red_team_discord_mentions).to eq "<@246107858712788993>, <@346107858712788994>"
    end
    it 'has a blue team' do
      expect(game.blue_team_discord_mentions).to eq "<@417766998471213061>, <@517766998471213062>"
    end
  end
end
