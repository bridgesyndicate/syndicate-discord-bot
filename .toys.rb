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
          name: 'red',
          description: 'Comma-separated list of red team',
          type: 3,
          required: true,
        },
        {
          name: 'blue',
          description: 'Comma-separated list of blue team',
          type: 3,
          required: true
        },
      ]
    }
    result = client.create_command(definition)
    puts JSON.pretty_generate(result)
  end
end
