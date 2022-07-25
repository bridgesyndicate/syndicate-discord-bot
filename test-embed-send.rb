#!/usr/bin/env ruby

# frozen_string_literal: true
require 'bundler'
require 'ostruct'
require 'time'
Bundler.require
require 'discordrb'
require 'discordrb/webhooks'

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'delayed_worker'
require 'discord_response_helper'
require 'game_maker'
require 'helpers'
require 'leaderboard'
require 'ranked'
require 'sqs_poller'
require 'syndicate_web_service'
require 'faker'
require 'ranked/match'

bot = Discordrb::Bot.new token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

#SyndicateWebService.user_by_discord_id_post([1])

binding.pry;1
puts 'foo'
exit

CHANNEL = 855996952348327949
HOOK = 906962753498013696

DiscordWebhookClient.instance.set_bot(bot)
discord_webhook_client = DiscordWebhookClient.instance

message = OpenStruct.new
message.body = File.read('./spec/mocks/new-game-sqs.json')
game_stream = GameStream.new(message)
if game_stream.process?
  if game_stream.new_game?
    discord_webhook_client.send_new_game_alert(game_stream.new_image)
  end
end
exit


def random_user
  { discord_id: rand(2**32),
    discord_username: Faker::Internet.username,
    queue_time: Time.now.to_i,
    elo: rand(2000)
  }
end


rom = Ranked::Storage.new.rom
players = Ranked::Player.new(rom)

5.times { players.create(random_user) }
all = players.sort_by_queue_time
match = Ranked::Match.new(all[0], all[1])

hook = DiscordWebhookClient.new(bot)
hook.send_new_game_alert(match, SecureRandom.uuid)

bot.button(custom_id: /^#{DiscordWebhookClient::SPECTATE_KEY}/) do |event|
  uuid = event.interaction.button.custom_id
           .split(DiscordWebhookClient::SPECTATE_KEY)
           .last
  event.respond(content: "<@#{event.user.id}> Adding you as a spectator to #{uuid}")
end


bot.run

