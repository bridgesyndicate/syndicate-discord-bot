#!/usr/bin/env ruby

# frozen_string_literal: true
require 'bundler'
require 'time'
Bundler.require
require 'discordrb'
require 'discordrb/webhooks'

$stdout.sync = true

Thread.abort_on_exception = true

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'secrets.rb'

WAITING_ROOM_ID = 855996952348327950

bot = Discordrb::Bot.new token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

def generate_knopfnsxoh_url(resource)
  if SYNDICATE_ENV == 'development'
    "http://localhost:4567/#{resource}"
  else
    "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/#{resource}"
  end
end

def make_game_json(blue_team_discord_ids:,
                   blue_team_discord_names:,
                   red_team_discord_ids:,
                   red_team_discord_names:,
                   goals:,
                   length:
                  )
  match = {
    uuid: SecureRandom.uuid,
    blue_team_discord_ids: blue_team_discord_ids,
    blue_team_discord_names: blue_team_discord_names,
    red_team_discord_ids: red_team_discord_ids,
    red_team_discord_names: red_team_discord_names,
    required_players: blue_team_discord_ids.size + red_team_discord_ids.size,
    accepted_by_discord_ids: blue_team_discord_ids.map{ |id|
      {
        discord_id: id,
        accepted_at: Time.now.utc.iso8601
      }
    },
    goals_to_win: goals,
    game_length_in_seconds: length,
    queued_at: Time.now.utc.iso8601,
    queued_via: 'discord duel slash command'
  }
  JSON.pretty_generate(match)
end

def get_sigv4_signer
  Aws::Sigv4::Signer.new(
    service: 'execute-api',
    credentials: AwsCredentials.instance.credentials,
    region: AwsCredentials.instance.region)
end

def sign_request(signer, method, url, body)
  signer.sign_request(
    http_method: method,
    url: url,
    body: body
  )
end

def send_game_to_syndicate_web_service(game_json)
  url = generate_knopfnsxoh_url('auth/game')
  signer = get_sigv4_signer
  signature = sign_request(signer, 'POST', url, game_json)
  uri = URI.parse(url)
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true unless SYNDICATE_ENV == 'development'
  req = Net::HTTP::Post.new(uri.path)
  header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
  header_list.each do |header|
    req[header] = signature.headers[header]
  end
  puts game_json if SYNDICATE_ENV == 'development'
  req.body = game_json
  https.request(req)
end

def register_with_syndicate_web_service(kick_code, discord_id)
  url = generate_knopfnsxoh_url("auth/register/by-kick-code/#{kick_code}/discord-id/#{discord_id}")
  signer = get_sigv4_signer
  signature = sign_request(signer, 'POST', url, '')
  uri = URI.parse(url)
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true unless SYNDICATE_ENV == 'development'
  req = Net::HTTP::Post.new(uri.path)
  header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
  header_list.each do |header|
    req[header] = signature.headers[header]
  end
  req.body = ''
  return https.request(req)
end

def accept_game_syndicate_web_service(uuid, discord_id)
  url = generate_knopfnsxoh_url("auth/game/accept/#{uuid}/discord-id/#{discord_id}")
  signer = get_sigv4_signer
  signature = sign_request(signer, 'POST', url, '')
  uri = URI.parse(url)
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true unless SYNDICATE_ENV == 'development'
  req = Net::HTTP::Post.new(uri.path)
  header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
  header_list.each do |header|
    req[header] = signature.headers[header]
  end
  req.body = ''
  return https.request(req)
end

DUEL_REQUEST_TAG='duel-request-uuid'

bot.application_command(:duel) do |event|
  blue_team_discord_ids = [event.user.id.to_s]
  red_team_discord_ids = [event.options['opponent']]
  blue_team_discord_names = blue_team_discord_ids.map {|id| event.server.member(id).username}
  red_team_discord_names = red_team_discord_ids.map {|id| event.server.member(id).username}
  goals = event.options['goals'] || 5
  length = event.options['length'] || 900
  game_json = make_game_json(
    blue_team_discord_ids: blue_team_discord_ids,
    red_team_discord_ids: red_team_discord_ids,
    blue_team_discord_names: blue_team_discord_names,
    red_team_discord_names: red_team_discord_names,
    goals: goals,
    length: length
  )

  status = send_game_to_syndicate_web_service(game_json)

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
  ret = accept_game_syndicate_web_service(uuid, discord_id)
  puts ret.inspect
  puts ret.body
  puts ret.to_hash.inspect
  event.update_message(content: "Accepted duel #{uuid}")
end

bot.application_command(:verify) do |event|
  kick_code = event.options['kick-code']
  response = register_with_syndicate_web_service(kick_code, event.user.id)
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

# $message_number = 0

bot.message do |event|
  # $message_number += 1
  # puts event.inspect

  # event.respond "processed message #{$message_number}"
  if false
    unless event.user.voice_channel.nil?
      unless event.user.voice_channel.id == WAITING_ROOM_ID
        event.respond "you are not in the Waiting Room"
        event.respond "your voice channel is: #{event.user.voice_channel.name}"
        event.respond "your voice channel is: #{event.user.voice_channel.id}"
      else
        event.respond 'you are in the waiting room'
      end
    else
      event.respond 'you must be in a voice channel'
    end
  end
end

$sqs_client = Aws::SQS::Client.new(credentials: AwsCredentials.instance.credentials)

WEBHOOK_URL = Secrets.instance.get_secret('discord-webhook-url')['DISCORD_WEBHOOK_URL']

$discord_webhook_client = Discordrb::Webhooks::Client.new(url: WEBHOOK_URL)

def send_discord_webhook(msg)
  $discord_webhook_client.execute do |builder|
    builder.add_embed do |embed|
      embed.title = msg
      embed.description = 'New IP for Direct Connect'
      embed.timestamp = Time.now.utc.iso8601
    end
  end
end

# binding.pry;1

SQS_QUEUE_URL='https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_player_messages'

def poll_sqs
  $stdout.sync = true
  while true
    res = $sqs_client.receive_message({
                                        queue_url: SQS_QUEUE_URL,
                                        wait_time_seconds: 20
    })
    unless res.to_h[:messages].nil?
      message = res.to_h[:messages][0]
      send_discord_webhook(JSON.parse(message[:body])["public_ip"])
      $sqs_client.delete_message({
        queue_url: SQS_QUEUE_URL,
        receipt_handle: message[:receipt_handle]
      })
    end
    sleep 1
  end
end

t = Thread.new { poll_sqs }

bot.run
t.join
