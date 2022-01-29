class Notifier
  attr_accessor :bot, :server_id, :game_uuid

  def initialize(bot, server_id)
    @bot = bot
    @server_id = server_id
    @game_uuid = SecureRandom.uuid
  end

  def notify(to_discord_id_list, from_discord_id)
    to_discord_id_list.each do |discord_id|
      send_embed(discord_id, from_discord_id)
    end
  end

  def send_embed(discord_id, from_discord_id)
    bot.server(server_id).member(discord_id).pm.send_embed() do |embed, view|
      embed.description = "Duel Request from <@#{from_discord_id}>"
      view.row do |r|
        r.button(
          label: 'Accept',
          style: :primary,
          custom_id: game_uuid
          )
      end
    end
  end
end