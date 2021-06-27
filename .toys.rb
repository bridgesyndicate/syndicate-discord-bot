$token = 'ODU2MzY5NzY0NzI5NjE4NDMy.YNACfg.0EfzhPl44YdmsYvLl8RyTvVyHHs'

tool 'hello' do
  def run
    puts 'Hello, world!'
  end
end

tool 'list-commands' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    result = client.list_commands
    puts JSON.pretty_generate(result)
  end
end

tool 'delete-command' do
  flag :command_id, '--command-id ID'
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    result = client.delete_command(command_id)
    puts JSON.pretty_generate(result)
  end
end

tool 'create-command' do  
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: "q",
      description: "Hop into the scrims queue",
      options: [
        {
          name: 'gamemode',
          description: 'Size of teams',
          type: 3,
          required: true,
          choices: [
            {
              name: '1v1',
              value: '1v1'
            },
            {
              name: '2v2',
              value: '2v2'
            },
            {
              name: '3v3',
              value: '3v3'
            },
            {
              name: '4v4',
              value: '4v4'
            }
          ]
        }
      ]
    }
    result = client.create_command(definition)
    puts JSON.pretty_generate(result)
  end
end