require "faraday"
require "json"

class DiscordApi

    def initialize(bot_token:, application_id:, guild_id:)
      @bot_token = bot_token
      @client_id = application_id
      @guild_id = guild_id
    end

    def list_guild_commands
      call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands")
    end

    def list_application_commands
      call_api("/applications/#{@client_id}/commands")
    end

    def delete_guild_command(command_id)
      call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands/#{command_id}",
                method: :delete)
    end

    def delete_application_command(command_id)
          call_api("/applications/#{@client_id}/commands/#{command_id}",
                    method: :delete)
        end

    def create_guild_command(command_definition)
      definition_json = JSON.dump(command_definition)
      headers = {"Content-Type" => "application/json"}
      puts JSON.pretty_generate(
             call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands",
                      method: :post,
                      body: definition_json,
                      headers: headers)
           )
    end

    def create_application_command(command_definition)
      definition_json = JSON.dump(command_definition)
      headers = {"Content-Type" => "application/json"}
      puts JSON.pretty_generate(
             call_api("/applications/#{@client_id}/commands",
                      method: :post,
                      body: definition_json,
                      headers: headers)
           )
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
