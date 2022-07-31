shared_context 'queued players' do
  let(:player_with_600_elo)  {
    {
      discord_id: rand(2**32).to_s,
      discord_username: 'harry',
      queue_time: now
    }
  }
  let(:player_without_elo) {
    {
      discord_id: rand(2**32).to_s,
      discord_username: 'ken',
      queue_time: now
    }
  }
  let(:p3) {
    {
      discord_id: rand(2**32).to_s,
      discord_username: 'joe',
      queue_time: now
    }
  }
  let(:p4) {
    {
      discord_id: rand(2**32).to_s,
      discord_username: 'ellis',
      queue_time: now
    }
  }
end
