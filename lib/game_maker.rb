class GameMaker
  def self.from_match(match)
    unless match.nil?
      puts "Making match player A: #{match.playerA.discord_id}, #{match.playerA.discord_username}"
      puts "Making match player B: #{match.playerB.discord_id}, #{match.playerB.discord_username}"
      blue_team_discord_ids = [match.playerA.discord_id.to_s]
      blue_team_discord_names = [match.playerA.discord_username]
      red_team_discord_ids = [match.playerB.discord_id.to_s]
      red_team_discord_names = [match.playerB.discord_username]
      goals = 1
      length = 120
      game = SyndicateWebService.make_game(
        via: 'queue match',
        blue_team_discord_ids: blue_team_discord_ids,
        red_team_discord_ids: red_team_discord_ids,
        blue_team_discord_names: blue_team_discord_names,
        red_team_discord_names: red_team_discord_names,
        goals: goals,
        length: length
      )
      game = SyndicateWebService.add_acceptance(game, match.playerB.discord_id.to_s)
      game_json = JSON.pretty_generate(game)
      status = SyndicateWebService.send_game_to_syndicate_web_service(game_json)
      unless status.class == Net::HTTPOK
        puts "Error making game from match #{match}, #{status}"
      end
    end
  end
end
