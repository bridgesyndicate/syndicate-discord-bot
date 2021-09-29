require 'secrets.rb'

class SyndicateWebService
  def self.generate_knopfnsxoh_url(resource)
    if SYNDICATE_ENV == 'development'
      "http://localhost:4567/#{resource}"
    else
      "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/#{resource}"
    end
  end

  def self.make_game_json(blue_team_discord_ids:,
                     blue_team_discord_names:,
                     red_team_discord_ids:,
                     red_team_discord_names:,
                     goals:,
                     length:
                    )
    match = {
      uuid: SecureRandom.uuid,
      blue_team_discord_ids: blue_team_discord_ids,
      blue_team_discord_names: blue_team_discord_names,
      red_team_discord_ids: red_team_discord_ids,
      red_team_discord_names: red_team_discord_names,
      required_players: blue_team_discord_ids.size + red_team_discord_ids.size,
      accepted_by_discord_ids: blue_team_discord_ids.map{ |id|
        {
          discord_id: id,
          accepted_at: Time.now.utc.iso8601
        }
      },
      goals_to_win: goals,
      game_length_in_seconds: length,
      queued_at: Time.now.utc.iso8601,
      queued_via: 'discord duel slash command'
    }
    JSON.pretty_generate(match)
  end

  def self.get_sigv4_signer
    Aws::Sigv4::Signer.new(
      service: 'execute-api',
      credentials: AwsCredentials.instance.credentials,
      region: AwsCredentials.instance.region)
  end

  def self.sign_request(signer, method, url, body)
    signer.sign_request(
      http_method: method,
      url: url,
      body: body
    )
  end

  def self.send_game_to_syndicate_web_service(game_json)
    url = generate_knopfnsxoh_url('auth/game')
    signer = get_sigv4_signer
    signature = sign_request(signer, 'POST', url, game_json)
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Post.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    puts game_json if SYNDICATE_ENV == 'development'
    req.body = game_json
    https.request(req)
  end

  def self.register_with_syndicate_web_service(kick_code, discord_id)
    url = generate_knopfnsxoh_url("auth/register/by-kick-code/#{kick_code}/discord-id/#{discord_id}")
    signer = get_sigv4_signer
    signature = sign_request(signer, 'POST', url, '')
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Post.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = ''
    return https.request(req)
  end

  def self.accept_game_syndicate_web_service(uuid, discord_id)
    url = generate_knopfnsxoh_url("auth/game/accept/#{uuid}/discord-id/#{discord_id}")
    signer = get_sigv4_signer
    signature = sign_request(signer, 'POST', url, '')
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Post.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = ''
    return https.request(req)
  end
end
