# coding: utf-8
require 'time'
require 'game'
require 'singleton'
require 'helpers'

class DiscordResponseHelper

  ICON_URL = 'https://s3.us-west-2.amazonaws.com/www.bridgesyndicate.gg/bridge-icon-128x128-transparent.png'

  def get_place_emoji(n)
    (%w/:first_place: :second_place: :third_place: :four: :five: :six: :seven:
       :eight: :nine: :keycap_ten:/)[n]
  end

  def build_description(leaderboard)
    leaderboard.each_with_index.map do |leader, idx|
      "#{get_place_emoji(idx)} #{format_discord_mention(leader.discord_id)} • #{leader.elo}"
    end.join("\n")
  end

  def send_leaderboard(leaderboard)
    [
      build_description(leaderboard),
      "",
      "_Season 0_"
    ].join("\n")
  end
end
