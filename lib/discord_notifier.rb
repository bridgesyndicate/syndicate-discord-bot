class DiscordNotifier
  attr_accessor :bot, :server_id, :game_uuid

  def initialize(bot, game_uuid)
    @bot = bot
    @server_id = DISCORD_SERVER_ID
    @game_uuid = game_uuid
  end

  def notify(from_discord_id, to_discord_id_list)
    to_discord_id_list.each do |discord_id|
      send_embed_to(discord_id, from_discord_id)
    end
  end

  def send_embed_to(to_discord_id, from_discord_id)
    bot.server(server_id).member(to_discord_id).pm.send_embed() do |embed, view|
      embed.description = "Duel Request from <@#{from_discord_id}>"
      view.row do |r|
        r.button(
          label: 'Accept',
          style: :primary,
          custom_id: "duel_accept_uuid_#{game_uuid}"
          )
      end
     end
  end
end
