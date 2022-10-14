require 'discordrb'
require 'aws-sigv4'
require 'bundler'
Bundler.require

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'secrets.rb'
require 'mock_secrets.rb'
require 'bot_config.rb'

BotConfig.load(File.read(ARGV.pop))
secrets_manager_klass = Object.const_get(BotConfig.config.secrets_manager_klass).instance
TOKEN = secrets_manager_klass.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']
APPLICATION_ID = BotConfig.config.discord_application_id
GUILD_ID = BotConfig.config.discord_guild_id

tool 'hello' do
  def run
    puts 'Hello, world!'
  end
end

tool 'list-application-commands' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    result = client.list_application_commands
    puts JSON.pretty_generate(result)
  end
end

tool 'list-guild-commands' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    result = client.list_guild_commands
    puts JSON.pretty_generate(result)
  end
end

tool 'delete-application-command' do
  required_arg :config
  flag :command_id, '--command-id ID'
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    result = client.delete_application_command(command_id)
    puts JSON.pretty_generate(result)
  end
end

tool 'delete-guild-command' do
  required_arg :config
  flag :command_id, '--command-id ID'
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    result = client.delete_guild_command(command_id)
    puts JSON.pretty_generate(result)
  end
end

tool 'create-duel-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    require_relative 'game_options'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
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
      ]
    }
    definition[:options] =
      definition[:options].concat(game_options) if BotConfig.config.include_duel_options
    client.create_application_command(definition)
  end
end

tool 'create-register-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'verify',
      description: 'Use a code to complete your registration',
      options: [
        {
          name: 'code',
          description: 'The code provided by our website',
          type: 3,
          required: true,
        }
      ]
    }
    client.create_application_command(definition)
  end
end

tool 'create-queue-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'q',
      description: 'Hop into the bridge queue.',
    }
    client.create_application_command(definition)
  end
end

tool 'create-dequeue-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'dq',
      description: 'Remove myself from the queue.',
    }
    client.create_application_command(definition)
  end
end

tool 'create-list-queue-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'list',
      description: 'List the queue',
    }
    client.create_application_command(definition)
  end
end

tool 'create-lb-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    require_relative 'lb_options'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'lb',
      description: 'Display the leaderboard',
    }
    definition[:options] = lb_options
    client.create_application_command(definition)
  end
end

tool 'create-party-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
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
    client.create_application_command(definition)
  end
end

tool 'create-ban-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'ban',
      description: 'Ban a player',
      options: [
        {
          name: 'ign',
          description: 'The Minecraft IGN of the player to ban',
          type: 3,
          required: true,
        }
      ]
    }
    client.create_application_command(definition)
  end
end

tool 'create-unban-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'unban',
      description: 'Unban a player',
      options: [
        {
          name: 'ign',
          description: 'The Minecraft IGN of the player to unban',
          type: 3,
          required: true,
        }
      ]
    }
    client.create_application_command(definition)
  end
end

tool 'create-unlock-command' do
  required_arg :config
  def run
    require_relative 'discord_api'
    client = DiscordApi.new(bot_token: TOKEN, application_id: APPLICATION_ID, guild_id: GUILD_ID)
    definition = {
      name: 'unlock',
      description: 'Unlocks a player',
      default_member_permissions: "0",
      dm_permission: false,
      options: [
        {
          name: 'discord_id',
          description: 'The Discord ID of the player to unlock',
          type: 3,
          required: true,
        }
      ]
    }
    client.create_application_command(definition)
  end
end

