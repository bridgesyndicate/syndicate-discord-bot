require 'spec_helper'
require 'game'
require 'bot_config'

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
        .to eq "<@882712836852301886>, <@246107858712788993>"
    end
    it 'gives the right winner names and elos' do
      expect(game.winner_names(:with_elo_changes))
        .to eq "<@882712836852301886> (+12), <@246107858712788993> (+11)"
    end
    it 'gives the right loser names' do
      expect(game.loser_names)
        .to eq "<@417766998471213061>, <@240177490906054658>"
    end
    it 'gives the right loser names and elos' do
      expect(game.loser_names(:with_elo_changes))
        .to eq "<@417766998471213061> (-11), <@240177490906054658> (-12)"
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
    let(:game_json) { File.read('./spec/mocks/2x2-game-score-with-season-sqs.json') }
    it_behaves_like 'base class'
    it_behaves_like 'finished games'
    it 'has a red team' do
      expect(game.red_team_discord_mentions).to eq "<@882712836852301886>, <@246107858712788993>"
    end
    it 'has a blue team' do
      expect(game.blue_team_discord_mentions).to eq "<@417766998471213061>, <@240177490906054658>"
    end
  end
  context 'tie game with season elo' do
    let(:game_json) { File.read('spec/mocks/tie-game-score-with-season-sqs.json') }
    it 'is a tie' do
      expect(game.tie).to eq true
      expect(game.winner_names(:with_elo_changes))
        .to eq '<@882712836852301886> (+7)'
      expect(game.winner_score).to eq 0
      expect(game.tie).to eq true
      expect(game.loser_names(:with_elo_changes))
        .to eq '<@246107858712788993> (-7)'
      expect(game.loser_score).to eq 0
    end
  end
  context 'with season elo' do
    let(:game_json) { File.read('./spec/mocks/2x2-game-score-with-season-sqs.json') }
    it 'gets the right winner name' do
      expect(game.winner_names)
        .to eq '<@882712836852301886>, <@246107858712788993>'
    end
    it 'gets the right loser name' do
      expect(game.loser_names)
        .to eq '<@417766998471213061>, <@240177490906054658>'
    end
    it 'gets the right winner elo' do
      expect(game.winner_names(:with_elo_changes))
        .to eq '<@882712836852301886> (+12), <@246107858712788993> (+11)'
    end
    it 'gets the right loser elo' do
      expect(game.loser_names(:with_elo_changes))
        .to eq '<@417766998471213061> (-11), <@240177490906054658> (-12)'
    end
  end
  context 'with season elo, other team wins' do
    let(:game_json) { File.read('./spec/mocks/2x2-game-score-with-season-sqs-other-team-wins.json') }
    it 'gets the right winner name' do
      expect(game.winner_names)
        .to eq '<@417766998471213061>, <@240177490906054658>'
    end
    it 'gets the right loser name' do
      expect(game.loser_names)
        .to eq '<@882712836852301886>, <@246107858712788993>'
    end
    it 'gets the right winner elo' do
      expect(game.winner_names(:with_elo_changes))
        .to eq '<@417766998471213061> (+11), <@240177490906054658> (+12)'
    end
    it 'gets the right loser elo' do
      expect(game.loser_names(:with_elo_changes))
        .to eq '<@882712836852301886> (-12), <@246107858712788993> (-11)'
    end
  end
  context 'without season elo' do
    let(:game_json) { File.read('./spec/mocks/1v1-game-score-without-season-sqs.json') }
    it 'gets the right winner name' do
      expect(game.winner_names)
        .to eq '<@246107858712788993>'
    end
    it 'gets the right loser name' do
      expect(game.loser_names)
        .to eq '<@882712836852301886>'
    end
    it 'does not format elo' do
      expect(game.winner_names(:with_elo_changes))
        .to eq '<@246107858712788993> '
    end
    it 'does not format elo' do
      expect(game.loser_names(:with_elo_changes))
        .to eq '<@882712836852301886> '
    end
  end
end
