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

require 'syndicate_web_service'

bot = Discordrb::Bot.new token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

bot.application_command(:duel) do |event|
  blue_team_discord_ids = [event.user.id.to_s]
  red_team_discord_ids = [event.options['opponent']]
  blue_team_discord_names = blue_team_discord_ids.map {|id| event.server.member(id).username}
  red_team_discord_names = red_team_discord_ids.map {|id| event.server.member(id).username}
  goals = event.options['goals'] || 5
  length = event.options['length'] || 900
  game_json = SyndicateWebService.make_game_json(
    blue_team_discord_ids: blue_team_discord_ids,
    red_team_discord_ids: red_team_discord_ids,
    blue_team_discord_names: blue_team_discord_names,
    red_team_discord_names: red_team_discord_names,
    goals: goals,
    length: length
  )

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
  when Net::HTTPBadRequest
    event.respond(content: "Invalid kick code format.")
  when Net::HTTPNotFound
    event.respond(content: "Your kick code was not found.")
  when Net::HTTPOK
    role = event.server.roles.select {|e| e.name == 'verified'}
    event.user.add_role(role)
    event.respond(content: "You are now verified!")
  end
end

bot.application_command(:q) do |event|
  event.respond(content: "Queued #{event.user.username}")
end

bot.application_command(:list) do |event|
  event.respond(content: "The current queue is :")
end

bot.run
