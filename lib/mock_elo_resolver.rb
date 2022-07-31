class MockEloResolver
  attr_accessor :discord_ids, :elo_map

  def resolve_elo_from_discord_ids
    @elo_map = {} if @elo_map.nil?
    Hash[ discord_ids.map {|v| [v, elo_map[v]? elo_map[v] : STARTING_ELO]}]
  end
end
