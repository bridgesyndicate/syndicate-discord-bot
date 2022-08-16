require 'spec_helper'
require 'scrims'
require_relative 'shared/leaderboard'

RSpec.describe '#leaderboard' do
  include_context 'mock leaderboard'

  before(:each) do
    @rom = Scrims::Storage.new.rom
    @leaderboard = Scrims::Leaderboard.new(@rom)
    @leaderboard.leaderboard_repo.create(lb_array_of_hashes)
    @seasons = [nil, 'season1', 'season2', 'season3'] # nil is the master season, with all stats combined
    @types = ['elo','wins','losses','ties']
    @discord_id = rand(2**32)
  end

  describe 'with a provided sorting argument' do
    it 'sorts the leaderboard by elo' do
      sorted_lb = @leaderboard.get_sorted_lb('elo', @seasons.sample)
      expect(sorted_lb.first[:elo] > sorted_lb.last[:elo])
    end
    it 'sorts the leaderboard by wins' do
      sorted_lb = @leaderboard.get_sorted_lb('wins', @seasons.sample)
      expect(sorted_lb.first[:wins] > sorted_lb.last[:wins])
    end
    it 'sorts the leaderboard by losses' do
      sorted_lb = @leaderboard.get_sorted_lb('losses', @seasons.sample)
      expect(sorted_lb.first[:losses] > sorted_lb.last[:losses])
    end
    it 'sorts the leaderboard by ties' do
      sorted_lb = @leaderboard.get_sorted_lb('ties', @seasons.sample)
      expect(sorted_lb.first[:ties] > sorted_lb.last[:ties])
    end
  end

  describe 'with a provided season' do
    let(:chosen_season) { @seasons.sample }
    it 'returns an array of hashes with the matching season' do
      sorted_lb = @leaderboard.get_sorted_lb(@types.sample, chosen_season)
      expect{
        sorted_lb.each do |entry|
          entry[:season] == chosen_season
        end
      }
    end
  end

  describe 'with a provided page argument' do
    let(:indexes_per_page) { 10 }
    let(:expected_number_of_newlines) { indexes_per_page - 1 }
    let(:type) { @types.sample }
    let(:season) { @seasons.sample }
    let(:first_page) { 1 }
    let(:last_page) { @leaderboard.get_sorted_lb(type, season).count / 10 + 1 }
    let(:out_of_bounds_page) { last_page + (rand(5) + 1) }
    let(:any_page) { rand(last_page) + 1 }

    describe 'with any available page' do
      it 'has the expected number of entries' do
        lb_formatted = @leaderboard.format_lb(type, any_page, season, @discord_id)
        expect(lb_formatted.scan(/\n/).length).to be <= expected_number_of_newlines
      end
    end
    describe 'with the first page' do
      it 'has the expected number of entries' do
        lb_formatted = @leaderboard.format_lb(type, first_page, season, @discord_id)
        expect(lb_formatted.scan(/\n/).length).to be <= expected_number_of_newlines
      end
    end
    describe 'with the last page' do
      it 'has the expected number of entries' do
        lb_formatted = @leaderboard.format_lb(type, last_page, season, @discord_id)
        expect(lb_formatted.scan(/\n/).length).to be <= expected_number_of_newlines
      end
    end
    describe 'with a page # > the # of pages' do
      it 'throws an exception' do
        expect{
          @leaderboard.format_lb(type, out_of_bounds_page, season, @discord_id)
        }.to raise_error Scrims::Leaderboard::PageOutOfBoundsError
      end
    end
  end

  describe 'requesters' do
    let(:sorted_lb) { @leaderboard.get_sorted_lb(@types.sample, @seasons.sample) }

    it 'includes an existent user in the lb response' do
      discord_id = sorted_lb.sample[:discord_id]
      expect(
        @leaderboard.requester_position(sorted_lb, @types.sample, discord_id)
      ).to include discord_id.to_s
    end
    it 'excludes a nonexistent user in the lb response' do
      discord_id = 2**32 + rand(2**32)
      expect(
        @leaderboard.requester_position(sorted_lb, @types.sample, discord_id)
      ).to eq ''
    end
  end

end