require 'rspec'
require 'ostruct'
require 'game_stream'

class GameStreamHelper
  attr_accessor :body
  def initialize(body)
    @body = body
  end
end

describe 'GameStream' do
  let(:game_stream_helper) { GameStreamHelper.new(json) }
  let(:game_stream) { GameStream.new(game_stream_helper) }

  context 'new game' do
    let(:json) { File.read('./spec/mocks/new-game-sqs.json') }

    it 'parses the event_name' do
      expect(game_stream.event_name).to eq 'MODIFY'
    end
    it 'is a new game' do
      expect(game_stream.new_game?).to eq true
    end
    it 'is not a game score' do
      expect(game_stream.game_score?).to eq false
    end
  end

  context 'abort' do
    let(:json) { File.read('./spec/mocks/aborted.json') }
    it 'processess it' do
      expect(game_stream.process?).to eq true
    end

    it 'parses as aborted' do
      expect(game_stream.aborted?).to eq true
    end
  end

  context 'game score' do
    let(:json) { File.read('./spec/mocks/game-score-sqs.json') }

    it 'parses the event_name' do
      expect(game_stream.event_name).to eq 'MODIFY'
    end
    it 'is not a new game' do
      expect(game_stream.new_game?).to eq false
    end
    it 'is a game score' do
      expect(game_stream.game_score?).to eq true
    end
  end
end
