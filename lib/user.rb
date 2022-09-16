require 'cache'
require 'syndicate_web_service'

class User
  class DiscordIdRequiredError < StandardError
  end
  class CouldNotPopulateUser < StandardError
  end
  class UnregisteredUser < StandardError
  end
  class BadRequest < StandardError
  end

  attr_accessor :properties, :discord_id

  def initialize(discord_id: nil)
    raise DiscordIdRequiredError if discord_id.nil?
    @discord_id = discord_id
    @properties = cache[discord_id].nil? ? cache[discord_id] = get_properties : cache[discord_id]
  end

  def cache
    Cache.instance.cache
  end

  def get_properties
    begin
      res = SyndicateWebService.new.get_user_record(discord_id)
    rescue
      raise CouldNotPopulateUser
    end
    case res
      when Net::HTTPOK
        properties = JSON.parse(res.body, symbolize_names: true)
      when Net::HTTPNotFound
        raise UnregisteredUser
      when Net::HTTPBadRequest
        raise BadRequest
      else
        raise CouldNotPopulateUser
        puts("Error: " + res.class)
    end
    return properties
  end

  def is_verified?
    !properties[:minecraft_uuid].nil?
  end

  def is_banned?
    properties[:banned]
  end

  def ban
    cache[discord_id][:banned] = true
  end

  def unban
    cache[discord_id].delete(:banned)
  end

  def add_verified_role(bot)
    discord_server = bot.server(BotConfig.config.discord_guild_id)
    member = discord_server.member(properties[:discord_id])
    member.add_role(DiscordAccess.get_verified_role(discord_server.roles)) unless member.nil?
  end

  def add_banned_role(bot)
    discord_server = bot.server(BotConfig.config.discord_guild_id)
    member = discord_server.member(properties[:discord_id])
    member.add_role(DiscordAccess.get_banned_role(discord_server.roles)) unless member.nil?
  end

  def remove_banned_role(bot)
    discord_server = bot.server(BotConfig.config.discord_guild_id)
    member = discord_server.member(properties[:discord_id])
    member.remove_role(DiscordAccess.get_banned_role(discord_server.roles)) unless member.nil?
  end
end

