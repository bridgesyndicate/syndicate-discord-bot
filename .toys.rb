require 'discordrb'
require 'aws-sigv4'

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'secrets.rb'

$token = Secrets.instance.get_secret('DISCORD_BOT_TOKEN')

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
        {
          name: 'goals',
          description: 'Number of goals to win',
          type: 4,
          required: false,
          choices: [
            {
                name: "1",
                value: 1
            },
            {
              name: "2",
              value: 2
            },
            {
              name: "3",
              value: 3
            },
            {
              name: "4",
              value: 4
            },
            {
              name: "5",
              value: 5
            }
          ]
        },
        {
          name: 'length',
          description: 'Length of game in minutes',
          type: 4,
          required: false,
          choices: [
            {
                name: "5",
                value: 300
            },
            {
              name: "10",
              value: 600
            },
            {
              name: "15",
              value: 900
            },
          ]
        },

      ]
    }
    result = client.create_command(definition)
    puts JSON.pretty_generate(result)
  end
end
