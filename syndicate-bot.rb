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

require 'delayed_worker'
require 'discord_response_helper'
require 'game_maker'
require 'helpers'
require 'leaderboard'
require 'ranked'
require 'sqs_poller'
require 'syndicate_web_service'

bot = Discordrb::Bot.new token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

queue = Ranked::Queue.new

Thread.abort_on_exception = true

bot.application_command(:duel) do |event|
  blue_team_discord_ids = [event.user.id.to_s]
  red_team_discord_ids = [event.options['opponent']]
  blue_team_discord_names = blue_team_discord_ids.map {|id| event.server.member(id).username}
  red_team_discord_names = red_team_discord_ids.map {|id| event.server.member(id).username}
  goals = event.options['goals'] || 5
  length = event.options['length'] || 900
  game = SyndicateWebService.make_game(
    via: 'discord duel slash command',
    blue_team_discord_ids: blue_team_discord_ids,
    red_team_discord_ids: red_team_discord_ids,
    blue_team_discord_names: blue_team_discord_names,
    red_team_discord_names: red_team_discord_names,
    goals: goals,
    length: length
  )
  game_json = JSON.pretty_generate(game)
  status = SyndicateWebService.send_game_to_syndicate_web_service(game_json)

  if status.class == Net::HTTPOK
    custom_id = "duel_accept_uuid_" + JSON.parse(game_json)['uuid']
    event.server.member(red_team_discord_ids.first).pm.send_embed() do |embed, view|
      embed.description = "Duel Request from <@#{event.user.id}>"
      view.row do |r|
        r.button(
          label: 'Accept',
          style: :primary,
          custom_id: custom_id
        )
      end
    end
    event.respond(
      content: "Your duel request has been sent. #{blue_team_discord_names.join(', ')} vs. #{red_team_discord_names.join(', ')}"
    )
  else
    puts "Could not send_game_to_syndicate_web_service. Status was: #{status}"
    event.respond(content: "Something went wrong")
  end
end

bot.button(custom_id: /^duel_accept_uuid_/) do |event|
  uuid = event.interaction.button.custom_id.split('duel_accept_uuid_')[1]
  discord_id = event.user.id.to_s
  ret = SyndicateWebService.accept_game_syndicate_web_service(uuid, discord_id)
  if status.class == Net::HTTPOK
    event.update_message(content: "Accepted duel #{uuid}")
  else
    event.respond(content: "Something went wrong.")
    puts ret.inspect
    puts ret.body
    puts ret.to_hash.inspect
  end
end

bot.application_command(:verify) do |event|
  kick_code = event.options['kick-code']
  response = SyndicateWebService.register_with_syndicate_web_service(kick_code, event.user.id)
  case response
  when Net::HTTPBadGateway
    event.respond(content: "Something went wrong.")
    puts "error. response is #{response}"
  when Net::HTTPBadRequest
    event.respond(content: "Invalid kick code format.")
  when Net::HTTPNotFound
    event.respond(content: "Your kick code was not found or is invalid.")
  when Net::HTTPOK
    role = event.server.roles.select {|e| e.name == 'verified'}
    event.user.add_role(role)
    event.respond(content: "You are now verified!")
  end
end

bot.application_command(:q) do |event|
  unless event.user.roles.map { |v|
           v.name.downcase }
           .include?("verified")
    event.respond(content: "You must be verified to queue.")
    break
  end

  puts "Request to join queue from #{event.user.id}, #{event.user.username}"

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
    event.respond(content: "#{event.user.username} is queued. Click below to dequeue.") do |_, view|
      view.row do |r|
        r.button(
          label: 'Dequeue',
          style: :danger,
          custom_id: 'XXXX'
        )
      end
    end
  else
    event.respond(content: "You are already queued")
  end
  DelayedWorker.new(Ranked::MAX_QUEUE_TIME) do
    GameMaker.from_match(queue.process_queue)
  end.run
  GameMaker.from_match(queue.process_queue)
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
  discord_embed_client = DiscordWebhookClient.instance
  discord_embed_client.send_leaderboard(leaderboard)
end

poller = SqsPoller.new
poller.run
bot.run
poller.join
