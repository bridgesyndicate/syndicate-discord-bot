require "faraday"
require "json"

class DiscordApi
    DISCORD_APPLICATION_ID = "856369764729618432"
    DISCORD_GUILD_ID = "855996952348327946"

    def initialize(bot_token:)
      @client_id = DISCORD_APPLICATION_ID
      @guild_id = DISCORD_GUILD_ID
      @bot_token = bot_token
    end

    def list_commands
      call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands")
#      call_api("/applications/#{@client_id}/commands")
    end

    def delete_command(command_id)
      call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands/#{command_id}",
                method: :delete)
#      call_api("/applications/#{@client_id}/commands/#{command_id}",
#                method: :delete)
    end

    def create_command(command_definition)
      definition_json = JSON.dump(command_definition)
      headers = {"Content-Type" => "application/json"}
      call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands",
              method: :post,
              body: definition_json,
              headers: headers)
    end

    private

    def call_api(path,
               method: :get,
               body: nil,
               params: nil,
               headers: nil)
    faraday = Faraday.new(url: "https://discord.com") do |conn|
      conn.authorization(:Bot, @bot_token)
    end

    response = faraday.run_request(method, "/api/v8#{path}", body, headers) do |req|
      req.params = params if params
    end
    unless (200...300).include?(response.status)
      raise "Discord API failure: #{response.status} #{response.body.inspect}"
    end
    return nil if response.body.nil? || response.body.empty?
    JSON.parse(response.body)
  end
end
