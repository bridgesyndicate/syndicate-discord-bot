require 'timecop'

class GameMaker
  attr_accessor :web_service, :party_repo, :lock_repo, :elo_resolver

  def initialize(web_service_klass: nil, party_repo: nil, lock_repo: nil, elo_resolver: nil)
    @web_service = web_service_klass
    @party_repo = party_repo
    @lock_repo = lock_repo
    @elo_resolver = elo_resolver
  end

  def make_game(blue_team_discord_ids:,
                     blue_team_discord_names:,
                     red_team_discord_ids:,
                     red_team_discord_names:,
                     goals:,
                     length:,
                     via:,
                     season:
                    )
    {
      uuid: SecureRandom.uuid,
      blue_team_discord_ids: blue_team_discord_ids,
      blue_team_discord_names: blue_team_discord_names,
      red_team_discord_ids: red_team_discord_ids,
      red_team_discord_names: red_team_discord_names,
      required_players: blue_team_discord_ids.size + red_team_discord_ids.size,
      goals_to_win: goals,
      game_length_in_seconds: length,
      queued_at: Time.now.utc.iso8601,
      accepted_by_discord_ids: (red_team_discord_ids + blue_team_discord_ids)
        .map{ |id|
        {
          discord_id: id,
          accepted_at: Time.now.utc.iso8601
        }
      },
      queued_via: via,
      season: season
    }
  end

  def self.make_team_duel(party1, party2)
    blue_team_discord_ids = party1
    red_team_discord_ids = party2
    blue_team_discord_names = blue_team_discord_ids.map {|id| event.server.member(id).username}
    red_team_discord_names = red_team_discord_ids.map {|id| event.server.member(id).username}
    goals = event.options['goals'] || 5
    length = event.options['length'] || 900
    game = GameMaker.make_game(
      via: 'discord duel slash command',
      blue_team_discord_ids: blue_team_discord_ids,
      red_team_discord_ids: red_team_discord_ids,
      blue_team_discord_names: blue_team_discord_names,
      red_team_discord_names: red_team_discord_names,
      goals: goals,
      length: length
    )
    JSON.pretty_generate(game)
  end

  def get_discord_ids(player)
    if player.party_id.nil?
      Array.new.push(player.discord_id.to_s)
    else
      party_repo.with_members(player.party_id).to_a.first.members.map{|m| m.discord_id}
    end
  end

  def get_discord_usernames(player)
    if player.party_id.nil?
      Array.new.push(player.discord_username)
    else
      party_repo.with_members(player.party_id).to_a.first.members.map{|m| m.discord_username}
    end
  end

  def get_elo_map(match)
    discord_ids = []
    if match.playerA.party_id.nil?
      discord_ids = [match.playerA.discord_id, match.playerB.discord_id]
    else
      discord_ids_a = party_repo.with_members(match.playerA.party_id).to_a.first.members.map{|m| m.discord_id}
      discord_ids_b = party_repo.with_members(match.playerB.party_id).to_a.first.members.map{|m| m.discord_id}
      syn_logger "Team A discord_ids: #{discord_ids_a}"
      syn_logger "Team B discord_ids: #{discord_ids_b}"
      discord_ids = discord_ids_a + discord_ids_b
    end
    elo_resolver.discord_ids = discord_ids
    elo_resolver.resolve_elo_from_discord_ids
  end

  def from_match(match)
    unless match.nil?
      syn_logger "Making match player A: #{match.playerA.discord_id || match.playerA.party_id}, #{match.playerA.discord_username}"
      syn_logger "Making match player B: #{match.playerB.discord_id || match.playerB.party_id}, #{match.playerB.discord_username}"
      blue_team_discord_ids = get_discord_ids(match.playerA)
      blue_team_discord_names = get_discord_usernames(match.playerA)
      red_team_discord_ids = get_discord_ids(match.playerB)
      red_team_discord_names = get_discord_usernames(match.playerB)
      lock_repo.lock_players(blue_team_discord_ids + red_team_discord_ids, 30.minutes)
      goals = 5
      length = 900
      season = BotConfig.config.current_season
      game = make_game(
        via: 'queue match',
        blue_team_discord_ids: blue_team_discord_ids,
        red_team_discord_ids: red_team_discord_ids,
        blue_team_discord_names: blue_team_discord_names,
        red_team_discord_names: red_team_discord_names,
        goals: goals,
        length: length,
        season: season
      )
      game = game.merge({ :elo_before_game => get_elo_map(match) })
      game_json = JSON.pretty_generate(game)
      syn_logger game_json
      status = web_service.send_game_to_syndicate_web_service(game_json)
      if status.class == Net::HTTPOK
        syn_logger "Sent new game #{match}, #{status}"
      else
        syn_logger "Error sending game from match #{match}, #{status}"
      end
    end
  end
end
