require 'syndicate_embeds'

class DiscordNotifier
  attr_accessor :bot, :server_id, :game_uuid

  def initialize(bot, game_uuid)
    @bot = bot
    @server_id = DISCORD_SERVER_ID
    @game_uuid = game_uuid
  end

  def notify(from_discord_id, to_discord_id_list, embed_discord_id_list)
    server = bot.server(server_id)
    to_discord_id_list.each do |discord_id|
      channel = server.member(discord_id).pm
      custom_id = "duel_accept_uuid_#{game_uuid}"
      begin
      SyndicateEmbeds::Builder.send(:duel_request,
                         channel: channel,
                         discord_id_list: embed_discord_id_list,
                         custom_id: custom_id)
      rescue Discordrb::Errors::NoPermission => e
        puts "We didn't have permission to embed_builder.send() to #{discord_id}"
      end
    end
  end
end
