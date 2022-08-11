shared_context 'mock leaderboard' do
  let(:seasons) { [nil, 'season1', 'season2', 'season3'] }
  let(:lb_array_of_hashes)  {
    (1..75).map { |m| {
      discord_id: rand(2**32),
      minecraft_uuid: SecureRandom.uuid.to_s,
      elo: rand(2000),
      wins: rand(100),
      losses: rand(100),
      ties: rand(15),
      season: seasons.sample
      }
    }
  }
end