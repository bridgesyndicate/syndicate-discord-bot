class DiscordResolver
  attr_accessor :bot, :server_id
  
  def initialize(bot, server_id)
    @bot = bot
    @server_id = server_id
  end
  
  def resolve_name_from_discord_id(discord_id)
    bot.server(server_id).member(discord_id).username
  end
end
