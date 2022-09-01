require 'cache'
require 'syndicate_web_service'

class User
  class DiscordIdRequiredError < StandardError
  end
  class CouldNotPopulateUser < StandardError
  end
  class UnregisteredUser < StandardError
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
      res = SyndicateWebService.get_user_record(discord_id)
    rescue
      raise CouldNotPopulateUser
    end
    raise UnregisteredUser if res.class == Net::HTTPNotFound
    return JSON.parse(res.body, symbolize_names: true) if res.class == Net::HTTPOK
    raise StandardError # should never get here
  end
end

