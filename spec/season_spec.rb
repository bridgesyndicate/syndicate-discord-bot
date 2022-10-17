require 'spec_helper'
require 'season'

RSpec.describe '#season clock' do
  let(:season) { Season.new }
  it 'is not in season on Thursday' do
    Timecop.freeze(Time.parse('Thu Oct 13 06:26:32 PDT 2022').utc) do
      expect(season.is_in_season?).to eq false
      expect(season.season_name).to match /^preseason/
    end
  end
  it 'is not in season early on Friday' do
    Timecop.freeze(Time.parse('Fri Oct 14 06:26:32 PDT 2022').utc) do
      expect(season.is_in_season?).to eq false
    end
  end
  it 'is in season later on Friday' do
    Timecop.freeze(Time.parse('Fri Oct 14 10:26:32 PDT 2022').utc) do
      expect(season.is_in_season?).to eq true
      expect(season.season_name).to match /^season/
    end
  end
  it 'is in season on Saturday' do
    Timecop.freeze(Time.parse('Sat Oct 15 03:26:32 PDT 2022').utc) do
      expect(season.is_in_season?).to eq true
    end
  end
  it 'was season1 on October 8, 2022' do
    Timecop.freeze(Time.parse('Sat Oct 08 03:26:32 PDT 2022').utc) do
      expect(season.season_number).to eq 1
      expect(season.season_name).to eq 'season1'
    end
  end
  it 'will be preseason2 on October 14, 2022 at 10:59' do
    Timecop.freeze(Time.parse('Fri Oct14 10:59:59 MDT 2022').utc) do
      expect(season.season_name).to eq 'preseason2'
    end
  end
  it 'will be season2 on October 14, 2022 at 11' do
    Timecop.freeze(Time.parse('Fri Oct14 11:00:00 MDT 2022').utc) do
      expect(season.season_name).to eq 'season2'
    end
  end
  it 'will be season2 on October 14, 2022 at 10 Pacific' do
    Timecop.freeze(Time.parse('Fri Oct14 10:00:00 PDT 2022').utc) do
      expect(season.season_name).to eq 'season2'
    end
  end
  it 'will be season2 on October 15, 2022' do
    Timecop.freeze(Time.parse('Sat Oct15 13:26:32 PDT 2022').utc) do
      expect(season.season_number).to eq 2
      expect(season.season_name).to eq 'season2'
    end
  end
  it 'is preseason2 on Thu Oct 13 07:26:45 PDT 2022' do
    Timecop.freeze(Time.parse('Thu Oct 13 07:26:45 PDT 2022').utc) do
      expect(season.season_name).to eq 'preseason2'
    end
  end
  it 'is preseason3 on Sun Oct 16 23:00:00 PDT 2022' do
    Timecop.freeze(Time.parse('Sun Oct 16 23:00:00 MDT 2022').utc) do
      expect(season.season_name).to eq 'preseason3'
    end
  end
  it 'is season15 on Sat Jan 14 11:30:15 MDT 2023' do
    Timecop.freeze(Time.parse('Sat Jan 14 11:30:15 MDT 2023').utc) do
      expect(season.season_name).to eq 'season15'
    end
  end
  it 'is season2 on Sun Oct 16 02:00:00 PDT 2022' do
    Timecop.freeze(Time.parse('Sun Oct 16 02:00:00 PDT 2022').utc) do
      expect(season.season_name).to eq 'season2'
    end
  end
end
