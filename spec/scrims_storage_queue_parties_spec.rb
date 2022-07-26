require 'spec_helper'
require 'scrims'
require 'timecop'

RSpec.describe '#parties in queue' do
  let(:discord_id_1) { rand(2**32).to_s }
  let(:discord_id_2) { rand(2**32).to_s }
  let(:discord_id_3) { rand(2**32).to_s }
  let(:discord_id_4) { rand(2**32).to_s }
  let(:num_users) { 3 }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @invites = Scrims::Invite.new(rom)
    @pid = @invites.accept(discord_id_1, discord_id_2)
    @queue = Scrims::Storage::Queue.new(rom)
  end

  it 'queues a party in sql' do
    @queue.create({ party_id: @pid,
                    queue_time: Time.now.to_i,
                    elo: rand(2000)
                  })
    expect(@queue.ids.size).to eq 1
  end
end

