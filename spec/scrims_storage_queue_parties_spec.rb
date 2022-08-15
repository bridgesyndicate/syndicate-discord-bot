require 'spec_helper'
require 'scrims'
require 'timecop'
require 'mock_elo_resolver'
require_relative 'shared/queued_players'

RSpec.describe '#parties in queue' do
  let(:discord_id_1) { rand(2**32).to_s }
  let(:discord_id_2) { rand(2**32).to_s }
  let(:discord_id_3) { rand(2**32).to_s }
  let(:discord_id_4) { rand(2**32).to_s }

  def random_user
    { discord_id: rand(2**32),
      discord_username: Faker::Internet.username,
      queue_time: Time.now.to_i,
      elo: rand(2000)
    }
  end

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invite.new(rom)
    @invites.discord_resolver = MockDiscordResolver.new
    @pid = @invites.accept(discord_id_1, discord_id_2)
    @queue = Scrims::Queue.new(rom)
    @queue.elo_resolver = MockEloResolver.new
  end

  it 'queues a party in sql' do
    @queue.queue_party({ party_id: @pid,
                         queue_time: Time.now.to_i,
                         elo: rand(2000)
                       })
    expect(@queue.size(party_size=2)).to eq 1
  end

  let(:elo) { rand(2000) }

  it 'throws an exception if the party is queued again' do
    @queue.queue_party({ party_id: @pid,
                         queue_time: Time.now.to_i,
                         elo: elo
                       })
    expect{
      @queue.queue_party({ party_id: @pid,
                           queue_time: Time.now.to_i,
                           elo: elo
                         })
    }.to raise_error Scrims::Queue::AlreadyQueuedError
  end

  it 'queues two parties in sql' do
    @pid2 = @invites.accept(discord_id_3, discord_id_4)
    @queue.queue_party({ party_id: @pid,
                    queue_time: Time.now.to_i,
                    elo: rand(2000)
                  })
    @queue.queue_party({ party_id: @pid2,
                    queue_time: Time.now.to_i,
                    elo: rand(2000)
                  })
    expect(@queue.size(party_size=2)).to eq 2
  end

  include_context 'queued players'
  let(:now) { Time.now.to_i }

  it 'processes a queue with two non-parties and two parties' do
    @pid2 = @invites.accept(discord_id_3, discord_id_4)
    @queue.queue_party({ party_id: @pid,
                    queue_time: Time.now.to_i,
                    elo: rand(2000)
                  })
    @queue.queue_party({ party_id: @pid2,
                    queue_time: Time.now.to_i,
                    elo: rand(2000)
                  })
    @queue.queue_player(p1)
    @queue.queue_player(p2)
    @queue.queue_player(p3)
    expect(@queue.process_queue.class).to eq Scrims::Match
    expect(@queue.size(party_size=1)).to eq 1
    expect(@queue.size).to eq 1
    expect(@queue.size(party_size=2)).to eq 2
  end
end

