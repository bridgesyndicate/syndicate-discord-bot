load 'spec_helper.rb'
require 'ranked'
require 'timecop'
require 'ranked/player'

RSpec.describe '#user model' do
  def random_user
    { discord_id: rand(2**32),
      discord_username: Faker::Internet.username,
      queue_time: Time.now.to_i,
      elo: rand(2000)
    }
  end

  describe 'sanity' do
    let(:num_users) { 3 }

    before(:each) do
      rom = Ranked::Storage.rom
      @players = Ranked::Player.new(rom)
    end

    describe 'from initial state' do
      it 'queues players in sql' do
        num_users.times { @players.create(random_user) }
        expect(@players.ids.size).to eq num_users
      end
      it 'creates players with default elo when no elo is set' do
        @players.create(random_user.reject{ |k| k == :elo})
        expect(@players.all.first.elo).to eq STARTING_ELO
      end
    end

    describe 'with players in the table' do
      before(:each) do
        @players.create( {
                         discord_id: 10,
                         discord_username: 'harry',
                         queue_time: 1700000000,
                         elo: 1100
                       }
                     )
        @players.create( {
                         discord_id: 20,
                         discord_username: 'ken',
                         queue_time: 1600000000,
                         elo: 900
                       }
                     )
        @players.create( {
                         discord_id: 30,
                         discord_username: 'izzy',
                         queue_time: 1500000000,
                         elo: 1000
                       }
                     )
      end

      it 'finds players by id' do
        expect(@players.by_id(10)).to be_a ROM::Struct::DiscordUserQueue
        expect(@players.by_id(10).discord_username).to eq 'harry'
      end
      it 'sorts players by queue_time' do
        expect(@players.sort_by_queue_time.map{|r| r.queue_time}).to eq [1500000000,
                                                                       1600000000,
                                                                       1700000000]
      end
      it 'sorts players by elo' do
        expect(@players.sort_by_elo.map{|r| r.elo}).to eq [900, 1000, 1100]
      end
    end
  end
end

