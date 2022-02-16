class Game
  attr_accessor :game, :uuid, :tie, :elo_change

  def initialize game
    @game = game
    @uuid = game.uuid
    make_elo_map unless game["elo_info"].nil?
    winner unless game.game_score.nil?
  end

  def make_elo_map
    @elo_change = {}
    game["elo_info"].each do |pair|
      @elo_change[pair.winner.discord_id] = pair.winner.end_elo - pair.winner.start_elo
      @elo_change[pair.loser.discord_id] = pair.loser.end_elo - pair.loser.start_elo
    end
  end

  def winner
    score = game.game_score
    score.red = BigDecimal(score.red).to_i
    score.blue = BigDecimal(score.blue).to_i
    diff = score.red - score.blue
    if diff > 0
      1
    elsif diff < 0
      -1
    else
      @tie = true
      0
    end
  end

  def profiles_from_ids(ids)
    ids.map do |id|
      "<@#{id}>"
    end.join(', ')
  end

  def change_string(change)
    indicator = change > 0 ? '+' : nil
    "(#{indicator}#{change})"
  end

  def profiles_and_elo_from_ids(ids)
    ids.map do |id|
      "<@#{id}> #{change_string(elo_change[id])}"
    end.join(', ')
  end

  def winner_score
    (winner == -1) ? game.game_score.blue : game.game_score.red
  end

  def loser_score
    (winner == -1) ? game.game_score.red : game.game_score.blue
  end

  def winner_names(*opts)
    if (opts.first == :with_elo_changes and BotConfig.config.show_elo)
      (winner == -1) ? profiles_and_elo_from_ids(game.blue_team_discord_ids) : profiles_and_elo_from_ids(game.red_team_discord_ids)
    else
      (winner == -1) ? profiles_from_ids(game.blue_team_discord_ids) : profiles_from_ids(game.red_team_discord_ids)
    end
  end

  def loser_names(*opts)
    if (opts.first == :with_elo_changes and BotConfig.config.show_elo)
      (winner == -1) ? profiles_and_elo_from_ids(game.red_team_discord_ids) : profiles_and_elo_from_ids(game.blue_team_discord_ids)
    else
      (winner == -1) ? profiles_from_ids(game.red_team_discord_ids) : profiles_from_ids(game.blue_team_discord_ids)
    end
  end

  def comparison_word
    (winner == 0 ) ? 'ties' : 'defeats'
  end

  def description
    "#{winner_names} (#{winner_score}) #{comparison_word} " +
      "#{loser_names} (#{loser_score})"
  end

  def red_team_discord_mentions
    profiles_from_ids(game.red_team_discord_ids)
  end

  def blue_team_discord_mentions
    profiles_from_ids(game.blue_team_discord_ids)
  end
end
