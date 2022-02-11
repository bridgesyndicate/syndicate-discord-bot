require 'rspec'
require 'ostruct'
require 'game_stream'
require 'aws-sdk-dynamodbstreams'

describe 'GameStream' do
  let(:game_stream) {
    GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                     .from_event(event).first)
  }

  context 'abort' do
    let(:event) { JSON.parse(File.read('./spec/mocks/aborted.json')) }
    it 'parses as aborted' do
      expect(game_stream.aborted?).to eq true
    end
  end
end
