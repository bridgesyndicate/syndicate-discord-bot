load 'spec_helper.rb'
require 'game.rb'

RSpec.describe '#game model' do
  let(:game_json) { File.read('spec/mocks/sqs-with-elo.json') }
  let(:message_struct) { JSON.parse(game_json, object_class: OpenStruct) }
  let(:game_struct) { message_struct.dynamodb.new_image.game }

  describe 'initialize' do
    it 'news' do
      expect(Game.new(game_struct).class).to eq Game
    end
    it 'gives the right winner names' do
      expect(Game.new(game_struct).winner_names)
        .to eq "<@246107858712788993>, <@346107858712788994>"
    end
    it 'gives the right winner names and elos' do
      expect(Game.new(game_struct).winner_names(:with_elo_changes))
        .to eq "<@246107858712788993> (+16), <@346107858712788994> (+15)"
    end
    it 'gives the right loser names' do
      expect(Game.new(game_struct).loser_names)
        .to eq "<@417766998471213061>, <@517766998471213062>"
    end
    it 'gives the right loser names and elos' do
      expect(Game.new(game_struct).loser_names(:with_elo_changes))
        .to eq "<@417766998471213061> (-16), <@517766998471213062> (-15)"
    end
  end
end

