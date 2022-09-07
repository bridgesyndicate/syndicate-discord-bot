require 'secrets.rb'

class SyndicateWebService
  attr_accessor :req, :body, :url, :uri, :signature, :method

  def generate_url(resource)
    if SYNDICATE_ENV == 'development'
      "http://localhost:4567/#{resource}"
    else
      "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/#{resource}"
    end
  end

  def get_sigv4_signer
    Aws::Sigv4::Signer.new(
      service: 'execute-api',
      credentials: AwsCredentials.instance.credentials,
      region: AwsCredentials.instance.region)
  end

  def sign_request(signer)
    signer.sign_request(
      http_method: method,
      url: url,
      body: body
    )
  end

  def header_list
    %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
  end

  def add_headers_to_request
    header_list.each do |header|
      @req[header] = @signature.headers[header]
    end
  end

  def get_request_signature
    signer = get_sigv4_signer
    syn_logger body unless body.nil? or body.empty?
    sign_request(signer)
  end

  def protocol
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true unless SYNDICATE_ENV == 'development'
    return http
  end

  def set_request
    case method
    when POST
      @req = Net::HTTP::Post.new(uri.path)
    else
      @req = Net::HTTP::Get.new(uri.path)
    end
    add_headers_to_request
    @req.body = body
  end

  def set_path(path)
    @url = generate_url(path)
    @uri = URI.parse(url)
  end

  def send_game_to_syndicate_web_service(game_json)
    @body = game_json
    @method = POST
    set_path('auth/game')
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end

  def get_user_record(discord_id)
    @method = GET
    set_path("auth/user/by-discord-id/#{discord_id}")
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end

  def register_with_syndicate_web_service(kick_code, discord_id)
    @method = POST
    set_path("auth/register/by-kick-code/#{kick_code}/discord-id/#{discord_id}")
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end

  def accept_game_syndicate_web_service(uuid, discord_id)
    @method = POST
    set_path("auth/game/accept/#{uuid}/discord-id/#{discord_id}")
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end

  def warp_game_syndicate_web_service(game_uuid, discord_id)
    @method = POST
    set_path("auth/warp/by-discord-id/#{discord_id}/to-game/#{game_uuid}")
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end

  def user_by_discord_id_post(discord_ids)
    @body = discord_ids.to_json
    @method = POST
    set_path("auth/user/by-discord-id")
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end

  def get_player_by_minecraft_name(minecraft_name)
    @method = GET
    set_path("auth/user/by-minecraft-name/#{minecraft_name}")
    @signature = get_request_signature
    set_request
    protocol.request(req)
  end
end
