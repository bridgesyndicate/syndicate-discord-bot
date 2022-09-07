require 'secrets.rb'

class SyndicateWebService
  def self.generate_knopfnsxoh_url(resource)
    if SYNDICATE_ENV == 'development'
      "http://localhost:4567/#{resource}"
    else
      "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/#{resource}"
    end
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
    begin
      https.request(req)
    rescue Exception => e
      e
    end
  end

  def self.get_user_record(discord_id)
    url = generate_knopfnsxoh_url("auth/user/by-discord-id/#{discord_id}")
    signer = get_sigv4_signer
    signature = sign_request(signer, 'GET', url, '')
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Get.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = ''
    return https.request(req)
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

  def self.warp_game_syndicate_web_service(game_uuid, discord_id)
    url = generate_knopfnsxoh_url(
      "auth/warp/by-discord-id/#{discord_id}/to-game/#{game_uuid}")
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

  def self.user_by_discord_id_post(discord_ids)
    url = generate_knopfnsxoh_url(
      "auth/user/by-discord-id")
    signer = get_sigv4_signer
    body = discord_ids.to_json
    signature = sign_request(signer, 'POST', url, body)
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Post.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = body
    return https.request(req)
  end

  def self.ban_player_by_minecraft_uuid(minecraft_uuid)
    url = generate_knopfnsxoh_url(
      "auth/ban")
    signer = get_sigv4_signer
    body = minecraft_uuid.to_json
    signature = sign_request(signer, 'POST', url, body)
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Post.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = body
    return https.request(req)
  end

  def self.unban_player_by_minecraft_uuid(minecraft_uuid)
    url = generate_knopfnsxoh_url("auth/ban/#{minecraft_uuid}")
    signer = get_sigv4_signer
    signature = sign_request(signer, 'DELETE', url, '')
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Delete.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = ''

    return https.request(req)
  end

  def self.get_player_by_minecraft_name(minecraft_name)
    url = generate_knopfnsxoh_url("auth/user/by-minecraft-name/#{minecraft_name}")
    signer = get_sigv4_signer
    signature = sign_request(signer, 'GET', url, '')
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true unless SYNDICATE_ENV == 'development'
    req = Net::HTTP::Get.new(uri.path)
    header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
    header_list.each do |header|
      req[header] = signature.headers[header]
    end
    req.body = ''
    return https.request(req)
  end
end
