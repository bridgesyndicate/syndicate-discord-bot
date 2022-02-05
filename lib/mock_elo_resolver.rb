class MockEloResolver
  attr_accessor :discord_ids

  def resolve_elo_from_discord_ids
    Hash[ discord_ids.map {|v| [v, rand(2000)]}]
  end
end
