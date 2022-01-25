require 'discordrb'
require 'aws-sigv4'
require 'bundler'
Bundler.require

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'secrets.rb'

$token = Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']

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

tool 'list-guild-commands' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    result = client.list_guild_commands
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

tool 'delete-guild-command' do
  flag :command_id, '--command-id ID'
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    result = client.delete_guild_command(command_id)
    puts JSON.pretty_generate(result)
  end
end

tool 'create-duel-command' do
  def run
    require_relative 'discord_api'
    require_relative 'game_options'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: 'duel',
      description: 'Challenge a verified player to a game of Bridge',
      options: [
        {
          name: 'opponent',
          description: 'Your opponent',
          type: 6,
          required: true,
        }
      ].concat(game_options)
    }
    client.create_application_and_guild_command(definition)
  end
end

tool 'create-register-command' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: 'verify',
      description: 'Use a kick code to complete your registration',
      options: [
        {
          name: 'kick-code',
          description: 'The kick code provided by our Minecraft server',
          type: 3,
          required: true,
        }
      ]
    }
    client.create_application_and_guild_command(definition)
  end
end

tool 'create-queue-command' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: 'q',
      description: 'Hop into the bridge queue.',
    }
    client.create_application_and_guild_command(definition)
  end
end

tool 'create-dequeue-command' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: 'dq',
      description: 'Remove myself from the queue.',
    }
    client.create_application_and_guild_command(definition)
  end
end

tool 'create-list-queue-command' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: 'list',
      description: 'List the queue',
    }
    client.create_application_and_guild_command(definition)
  end
end

tool 'create-lb-command' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: 'lb',
      description: 'Display the leaderboard',
    }
    client.create_application_and_guild_command(definition)
  end
end

tool 'create-party-command' do
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: $token)
    definition = {
      name: "party",
      description: "Party commands",
      options: [
        {
          name: "invite",
          description: "Invite a player to your party",
          type: 1, # 1 is type SUB_COMMAND
          options: [
            {
              name: 'player',
              description: 'The player to invite to your party',
              type: 6, # 6 is type USER
              required: true
            },
          ]
        },
        {
          name: 'list',
          description: 'List the players in your party',
          type: 1,
        },
        {
          name: 'leave',
          description: 'Leave your party',
          type: 1,
        }
      ]
    }
    client.create_guild_command(definition)
  end
end
