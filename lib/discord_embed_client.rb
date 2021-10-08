require 'time'
require 'game'

class DiscordEmbedClient
  include Singleton

  BRIDGE_ICON_THUMB = 'https://s3.us-west-2.amazonaws.com/www.bridgesyndicate.gg/bridge-icon-128x128-transparent.png'
  BRIDGE_FQDN = 'bridgesyndicate.gg'
  BRIDGE_HOME_URL = "https://#{BRIDGE_FQDN}/"
  attr_accessor :discord_webhook_client

  def initialize
    webhook_url = Secrets.instance.get_secret('discord-webhook-url')['DISCORD_WEBHOOK_URL']
    @discord_webhook_client = Discordrb::Webhooks::Client.new(url: webhook_url)
  end

  def send_new_game_alert(match)
    discord_webhook_client.execute do |builder|
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
        embed.add_field(name: "player",
                        value: "#{match.playerA.discord_username}",
                        inline: true)
        embed.add_field(name: "player",
                        value: "#{match.playerB.discord_username}",
                        inline: true)
      end
    end
  end

  def send_new_game_score(msg)
    game = Game.new(msg.game)

    discord_webhook_client.execute do |builder|
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
        embed.add_field(name: ":regional_indicator_w:",
                        value: "#{game.winner_names}\n#{game.winner_score}",
                        inline: true)
        embed.add_field(name: ":regional_indicator_l:",
                        value: "#{game.loser_names}\n#{game.loser_score}",
                        inline: true)
      end
    end
  end
end
