class MockEloResolver
  attr_accessor :discord_ids, :elo_map

  def random_season_name
  (rand(8)+2).times.map{|i| (97 + rand(26)).chr}.join
  end

  def random_season_elos
    rand(4).times
      .map {|i| { random_season_name => rand(2000)} }
      .reduce({}, :merge!)
  end

  def random_elos
    discord_ids
      .map { |discord_id| { discord_id => {
          'elo' => rand(1000),
          'season_elos' => random_season_elos
        }
      }
    }
      .reduce({}, :merge!)
  end

  def resolve_elo_from_discord_ids
    elo_map.nil? ? random_elos : elo_map.select{ |k| discord_ids.include?(k) }
  end
end
