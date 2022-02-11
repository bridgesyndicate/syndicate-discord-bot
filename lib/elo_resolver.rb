require 'syndicate_web_service'

class EloResolver
  class SyndicateWebServiceError < StandardError
  end

  attr_accessor :discord_ids

  def fetch_elo_from_web_service
    res = SyndicateWebService.user_by_discord_id_post(discord_ids)
    if res.class == Net::HTTPOK
      JSON.parse(res.body)
    else
      puts res.inspect
      puts res.body
      puts res.to_hash.inspect
      raise SyndicateWebServiceError
    end
  end

  def resolve_elo_from_discord_ids
    fetch_elo_from_web_service
      .transform_values do |v|
      v.nil? ? STARTING_ELO : v
    end
  end
end
