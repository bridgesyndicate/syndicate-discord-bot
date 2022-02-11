# coding: utf-8
require 'time'
require 'game'
require 'singleton'
require 'helpers'

class DiscordWebhookClient
  include Singleton

  SPECTATE_KEY = 'spectate-'
  BRIDGE_ICON_THUMB = 'https://s3.us-west-2.amazonaws.com/www.bridgesyndicate.gg/bridge-icon-128x128-transparent.png'
  BRIDGE_FQDN = 'bridgesyndicate.gg'
  BRIDGE_HOME_URL = "https://#{BRIDGE_FQDN}/"
  CHANNEL = 941539084474671166
  HOOK = 941557044949971014
  CUSTOM_EMOJI_WIN = '<:win:907177703810170891>'
  CUSTOM_EMOJI_LOSS = '<:loss:907177703751450674>'
  CUSTOM_EMOJI_TIE = '<:tie:907177703642394634>'
  CUSTOM_EMOJI_RED = '<:r_for_red:908161726543982654>'
  CUSTOM_EMOJI_BLUE = '<:b_for_blue:908161738510307368>'

  attr_accessor :webhook

  def set_bot(bot)
    @webhook = bot.channel(CHANNEL).webhooks
         .filter { |h| h.id == HOOK }
         .first
  end

  def send_new_game_alert(msg, with_spectate_button=true)
    game = Game.new(msg.game)
    webhook.execute do |builder, view|
      builder.add_embed do |embed|
        embed.title = "New Match"
        embed.colour = '0x4b7bbf'
        embed.url = "#{BRIDGE_HOME_URL}"
        embed.timestamp = Time.now
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail
                            .new(url: BRIDGE_ICON_THUMB)
        embed.author = Discordrb::Webhooks::EmbedAuthor
                         .new(name: BRIDGE_FQDN,
                              url: BRIDGE_HOME_URL,
                              icon_url: BRIDGE_ICON_THUMB)
        embed.add_field(name: CUSTOM_EMOJI_BLUE,
                        value: "#{game.red_team_discord_mentions}",
                        inline: true)
        embed.add_field(name: CUSTOM_EMOJI_RED,
                        value: "#{game.blue_team_discord_mentions}",
                        inline: true)
        if with_spectate_button
          view.row do |r|
            r.button(
              label: 'Spectate',
              style: :secondary,
              custom_id: "#{SPECTATE_KEY}#{game.uuid}"
            )
          end
        end
      end
    end
  end

  def send_game_score(msg)
    game = Game.new(msg.game)
    webhook.execute do |builder|
      builder.add_embed do |embed|
        embed.title = "Match Results"
        embed.colour = '0x4b7bbf'
        embed.url = "#{BRIDGE_HOME_URL}/g/#{game.uuid}"
        embed.timestamp = Time.now
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail
                            .new(url: BRIDGE_ICON_THUMB)
        embed.author = Discordrb::Webhooks::EmbedAuthor
                         .new(name: BRIDGE_FQDN,
                              url: BRIDGE_HOME_URL,
                              icon_url: BRIDGE_ICON_THUMB)
        embed.add_field(name: game.tie ? CUSTOM_EMOJI_TIE : CUSTOM_EMOJI_WIN,
                        value: "#{game.winner_names(:with_elo_changes)}\n#{game.winner_score}",
                        inline: true)
        embed.add_field(name: game.tie ? CUSTOM_EMOJI_TIE : CUSTOM_EMOJI_LOSS,
                        value: "#{game.loser_names(:with_elo_changes)}\n#{game.loser_score}",
                        inline: true)
      end
    end
  end

  def get_place_emoji(n)
    (%w/:first_place: :second_place: :third_place: :four: :five: :six: :seven:
       :eight: :nine: :keycap_ten:/)[n]
  end

  def build_description(leaderboard)
    leaderboard.each_with_index.map do |leader, idx|
      "#{get_place_emoji(idx)} #{format_discord_mention(leader.discord_id)} • #{leader.elo} (#{leader.wins}/#{leader.losses}/#{leader.ties})"
    end.join("\n")
  end

  def send_leaderboard(leaderboard)
    webhook.execute do |builder|
      builder.add_embed do |embed|
        embed.description = build_description(leaderboard)
        embed.title = "Leaderboard"
        embed.colour = '0x2f3137'
        embed.timestamp = Time.now
        embed.footer = Discordrb::Webhooks::EmbedFooter
                         .new(text: "Season 0",
                              icon_url: 'https://s3.us-west-2.amazonaws.com/www.bridgesyndicate.gg/bridge-icon-128x128-transparent.png')
      end
    end
  end
end
