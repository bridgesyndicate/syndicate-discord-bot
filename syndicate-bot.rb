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
BotConfig.load(File.read('./config.yml'), :buckytour_test)

require 'delayed_worker'
require 'discord_response_helper'
require 'game_maker'
require 'helpers'
require 'leaderboard'
require 'ranked'
require 'sqs_poller'
require 'syndicate_web_service'
require 'slash_cmd_handler'
require 'discord_access'

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

opts = { token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN'] }
opts.merge(log_mode: :debug) if SYNDICATE_ENV == 'production'
bot = Discordrb::Bot.new(opts)
DiscordWebhookClient.instance.set_bot(bot)

queue = Ranked::Queue.new

Thread.abort_on_exception = true

$scrims_storage_rom = Scrims::Storage.new.rom

bot.button(custom_id: /^#{DiscordWebhookClient::SPECTATE_KEY}/) do |event|
  discord_id = event.user.id
  game_uuid = event.interaction.button.custom_id
           .split(DiscordWebhookClient::SPECTATE_KEY)
           .last
  ret = SyndicateWebService.warp_game_syndicate_web_service(game_uuid, discord_id)
  if ret.class == Net::HTTPOK
    event.respond(content: "<@#{event.user.id}> Adding you as a spectator to #{game_uuid}")
  elsif ret.class == Net::HTTPNotFound
    event.respond(content: JSON.parse(ret.body)['reason'])
  else
    event.respond(content: "Something went wrong.")
    puts ret.inspect
    puts ret.body
    puts ret.to_hash.inspect
  end
end

bot.application_command(:q) do |event|
  puts "Request to queue from #{event.user.id}, #{event.user.username}"

  next unless ensure_verified_user(event)

  response = SyndicateWebService.get_user_record(event.user.id)
  unless response.class == Net::HTTPOK
    event.respond(content: "We encountered an error.")
    puts "error: cannot fetch user for #{event.user.id}"
    break
  end

  user = JSON.parse(response.body)
  queue_params = {
    discord_id: event.user.id,
    discord_username: event.user.username,
    queue_time: Time.now.to_i,
  }
  queue_params.merge!(elo: user['elo']) if user['elo']
  puts "queue_params for #{event.user.id} are #{queue_params}"
  begin
    queue.queue_player(queue_params)
  rescue ROM::SQL::UniqueConstraintError => e
  end
  if e.nil?
    event.respond(content: "#{event.user.username} is queued. Type /dq to dequeue.")
  else
    event.respond(content: "You are already queued")
  end
  DelayedWorker.new(Ranked::MAX_QUEUE_TIME) do
    GameMaker.from_match(queue.process_queue)
  end.run
  GameMaker.from_match(queue.process_queue)
end

bot.application_command(:dq) do |event|
  puts "Request to dequeue from #{event.user.id}, #{event.user.username}"

  if queue.dequeue_player(event.user.id) == 1
    event.respond(content: "#{event.user.username}(#{event.user.id}) has been removed from the queue.")
  else
    event.respond(content: "You are not in the queue.")
  end
end

bot.application_command(:list) do |event|
  queue_members = queue.queue.all
                    .map{ |u| "#{u.discord_username}|#{u.elo}" }
                    .join(', ')
  event.respond(content: "The current queue is : #{queue_members}")
end

bot.application_command(:lb) do |event|
  rom = Leaderboard.rom
  leaderboard = Leaderboard.new(rom).sort_by_elo
  event.respond(content: 'The current leaderboard:')
  DiscordWebhookClient.instance.send_leaderboard(leaderboard)
end

SlashCmdHandler::Party.new(bot).add_handlers
SlashCmdHandler::Duel.new(bot).add_handlers
SlashCmdHandler::Barr.new(bot).add_handlers
SlashCmdHandler::Verify.init(bot)

poller = SqsPoller.new
poller.run
bot.run
poller.join
