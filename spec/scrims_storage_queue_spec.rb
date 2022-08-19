require 'spec_helper'
require 'scrims'
require 'timecop'

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
      rom = Scrims::Storage.new.rom
      @queue = Scrims::Storage::Queue.new(rom)
    end

    describe 'from initial state' do
      it 'queues players in sql' do
        num_users.times { @queue.create(random_user) }
        expect(@queue.ids.size).to eq num_users
      end
      it 'fails to create players when no elo is set' do
        expect {
          @queue.create(random_user.reject{ |k| k == :elo})
        }.to raise_error ROM::SQL::NotNullConstraintError
      end
    end

    describe 'with players in the table' do
      before(:each) do
        @queue.create( {
                         discord_id: 10,
                         discord_username: 'harry',
                         queue_time: 1700000000,
                         elo: 1100
                       }
                     )
        @queue.create( {
                         discord_id: 20,
                         discord_username: 'ken',
                         queue_time: 1600000000,
                         elo: 900
                       }
                     )
        @queue.create( {
                         discord_id: 30,
                         discord_username: 'izzy',
                         queue_time: 1500000000,
                         elo: 1000
                       }
                     )
      end

      it 'finds players by id' do
        expect(@queue.by_discord_id(10).count).to eq 1
        expect(@queue.by_discord_id(10).one.discord_username).to eq 'harry'
      end

      it 'has a delete method' do
        expect(@queue.by_discord_id(10).methods.grep(/delete/).size).to eq 1
      end
      it 'sorts players by queue_time' do
        expect(@queue.sort_by_queue_time.map{|r| r.queue_time}).to eq [1500000000,
                                                                       1600000000,
                                                                       1700000000]
      end
      it 'sorts players by elo' do
        expect(@queue.sort_by_elo.map{|r| r.elo}).to eq [900, 1000, 1100]
      end
    end
  end
end

