require 'syndicate_web_service'

class EloResolver
  class SyndicateWebServiceError < StandardError
  end

  attr_accessor :discord_ids

  def resolve_elo_from_discord_ids
    res = SyndicateWebService.new.user_by_discord_id_post(discord_ids)
    if res.class == Net::HTTPOK
      JSON.parse(res.body)
    else
      puts res.inspect
      puts res.body
      puts res.to_hash.inspect
      raise SyndicateWebServiceError
    end
  end
end
