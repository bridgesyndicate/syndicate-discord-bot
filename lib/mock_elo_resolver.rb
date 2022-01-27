class MockEloResolver
  def resolve_elo_from_discord_ids(discord_ids)
    Hash[ discord_ids.map {|v| [v, rand(2000)]}]
  end
end
