require 'time'
require 'game'

class DiscordEmbedClient
  attr_accessor :discord_webhook_client

  def initialize
    webhook_url = Secrets.instance.get_secret('discord-webhook-url')['DISCORD_WEBHOOK_URL']
    @discord_webhook_client = Discordrb::Webhooks::Client.new(url: webhook_url)
  end

  def send_new_game_score(msg)
    game = Game.new(msg.game)

    discord_webhook_client.execute do |builder|
      builder.add_embed do |embed|
        embed.title = 'New Game Results'
        embed.description = game.description
        embed.timestamp = Time.now
      end
    end
  end
end
