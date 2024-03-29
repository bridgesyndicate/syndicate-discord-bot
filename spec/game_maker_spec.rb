require 'spec_helper'
require 'mock_syndicate_web_service'
require 'mock_party_repo'
require 'mock_elo_resolver'
require 'game_maker'
require 'scrims'
require 'scrims/match'
require 'schema/game_post'

RSpec.describe '#game maker' do

  before(:each) do
    rom = Scrims::Storage.new.rom
    @lock_repo = Scrims::Locks.new(rom)
  end

  let(:p1) { OpenStruct.new({ discord_id: rand(2**32).to_s,
                              discord_username: Faker::Internet.username }) }
  let(:p2) { OpenStruct.new({ discord_id: rand(2**32).to_s,
                              discord_username: Faker::Internet.username }) }
  let(:p3) { OpenStruct.new({ discord_id: rand(2**32).to_s,
                              discord_username: Faker::Internet.username }) }
  let(:p4) { OpenStruct.new({ discord_id: rand(2**32).to_s,
                              discord_username: Faker::Internet.username }) }

  describe 'with a match that is players' do
    let(:match) { Scrims::Match.new(p1, p2) }
    let(:elo_resolver) { MockEloResolver.new }
    let(:game_maker) { GameMaker.new(web_service_klass: MockSyndicateWebService,
                                     lock_repo: @lock_repo,
                                     elo_resolver: elo_resolver) }
    let(:game) { game_maker.from_match(match) }

    it 'makes a match with klass foo' do
      expect(match.playerA).to be_a OpenStruct
      expect(match.playerB).to be_a OpenStruct
    end

    it 'makes the expected json' do
      http_status = game
      json = game_maker.web_service.class_variable_get(:@@game_json)
      expect(JSON::Validator.validate(GamePostSchema.schema, json))
        .to be true
    end

    it 'locks both of the players' do
      http_status = game
      discord_id_list = [match.playerA.discord_id, match.playerB.discord_id]
      expect(@lock_repo.locked?(discord_id_list))
        .to be true
    end
  end

  describe 'with a match that is parties' do
    let(:party1) { OpenStruct.new({ party_id: 1 }) }
    let(:party2) { OpenStruct.new({ party_id: 2 }) }
    let(:match) { Scrims::Match.new(party1, party2) }
    let(:elo_resolver) { MockEloResolver.new }
    let(:party_repo) { MockPartyRepo.new( {
                                            1 => [p1, p2],
                                            2 => [p3, p4]
                                          }
                                          )}
    let(:game_maker) { GameMaker.new(web_service_klass: MockSyndicateWebService,
                                     party_repo: party_repo,
                                     lock_repo: @lock_repo,
                                     elo_resolver: elo_resolver) }
    let(:game) { game_maker.from_match(match) }

    it 'makes a match with klass foo' do
      expect(match.playerA).to be_a OpenStruct
      expect(match.playerB).to be_a OpenStruct
    end

    it 'makes the expected json' do
      http_status = game
      json = game_maker.web_service.class_variable_get(:@@game_json)
      expect(JSON::Validator.validate(GamePostSchema.schema, json))
        .to be true
    end

    it 'locks all of the players from both parties' do
      http_status = game
      discord_id_list = party_repo.with_members(match.playerA.party_id).first.members.map { |member| member.discord_id } +\
                          party_repo.with_members(match.playerB.party_id).first.members.map { |member| member.discord_id }
      expect(@lock_repo.locked?(discord_id_list))
        .to be true
    end
  end
end
