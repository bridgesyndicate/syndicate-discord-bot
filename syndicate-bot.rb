#!/usr/bin/env ruby

# frozen_string_literal: true
require 'bundler'
require 'time'
Bundler.require
require 'discordrb'
require 'discordrb/webhooks'
require 'rom-repository'

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'bot_config'
BotConfig.load(File.read('./config.yml'), :syndicate)

require 'delayed_worker'
require 'discord_response_helper'
require 'game_maker'
require 'helpers'
require 'leaderboard'
require 'sqs_poller'
require 'syndicate_web_service'
require 'slash_cmd_handler'
require 'discord_access'
require 'welcome_message'

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

opts = { token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN'] }
opts.merge(log_mode: :debug) if SYNDICATE_ENV == 'production'
bot = Discordrb::Bot.new(opts)
DiscordWebhookClient.instance.set_bot(bot)

$rom = Scrims::Storage.new.rom

Thread.abort_on_exception = true

bot.button(custom_id: /^#{DiscordWebhookClient::SPECTATE_KEY}/) do |event|
  discord_id = event.user.id
  game_uuid = event.interaction.button.custom_id
           .split(DiscordWebhookClient::SPECTATE_KEY)
           .last
  ret = SyndicateWebService.warp_game_syndicate_web_service(game_uuid, discord_id)
  puts "#{event.user.id}, #{event.user.username} clicking spectate on #{game_uuid}"
  if ret.class == Net::HTTPOK
    event.respond(content: "<@#{event.user.id}> Adding you as a spectator to this game", ephemeral: true)
  elsif ret.class == Net::HTTPNotFound
    event.respond(content: JSON.parse(ret.body)['reason'], ephemeral: true)
  else
    event.respond(content: "Something went wrong.", ephemeral: true)
    puts ret.inspect
    puts ret.body
    puts ret.to_hash.inspect
  end
end

bot.application_command(:list) do |event|
  queue_members = queue.queue.all
                    .map{ |u| "#{u.discord_username}|#{u.elo}" }
                    .join(', ')
  event.respond(content: "The current queue is : #{queue_members}")
end

queue = Scrims::Queue.new($rom)
leaderboard = Scrims::Leaderboard.new($rom)

SlashCmdHandler::Party.new(bot).add_handlers
SlashCmdHandler::Duel.new(bot).add_handlers
SlashCmdHandler::Barr.new(bot).add_handlers
SlashCmdHandler::Queue.new(bot, queue).add_handlers
SlashCmdHandler::Dequeue.new(bot, queue).add_handlers
SlashCmdHandler::Leaderboard.new(bot, leaderboard).add_handlers
SlashCmdHandler::Verify.init(bot)
WelcomeMessage.init(bot)

poller = SqsPoller.new
poller.run
bot.run
poller.join
