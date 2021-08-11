#!/usr/bin/env ruby

# frozen_string_literal: true

require 'discordrb'
require 'discordrb/webhooks'
require 'aws-sigv4'
require 'aws-sdk-sqs'
# require 'pry'

Thread.abort_on_exception = true

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'secrets.rb'

WAITING_ROOM_ID = 855996952348327950
BASE_URL = 'https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/game'

# bot = Discordrb::Bot.new token: Secrets.instance.get_secret('discord-bot-token')['DISCORD_BOT_TOKEN']

def make_game_json(red, blue, goals, length)
  match = {
    blueTeam: blue.split(/,\s*/),
    redTeam:  red.split(/,\s*/),
    requiredPlayers: blue.split(/,\s*/).size + red.split(/,\s*/).size,
    goalsToWin: goals,
    gameLengthInSeconds: length
  }
  JSON.pretty_generate(match)
end


def send_game_to_syndicate_web_service(game_json)
  signer = Aws::Sigv4::Signer.new(
                                  service: 'execute-api'
                                  )

  signature = signer.sign_request(
                                  http_method: 'POST',
                                  url: BASE_URL,
                                  body: game_json
                                  )
  uri = URI.parse(BASE_URL)
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new(uri.path)
  header_list = %w/host x-amz-date x-amz-security-token x-amz-content-sha256 authorization/
  header_list.each do |header|
    req[header] = signature.headers[header]
  end
  req.body = game_json
  ret = https.request(req)
  if ret.class == Net::HTTPSuccess
    return ret.body
  else
    return ret.to_s
  end
end

if false
bot.application_command(:q) do |event|
  red = event.options['red']
  blue = event.options['blue']
  goals = event.options['goals'] || 5
  length = event.options['length'] || 900
  game_json = make_game_json(red, blue, goals, length)
  event.respond(content: "your game is #{red} vs. #{blue} with json of #{game_json} #{send_game_to_syndicate_web_service(game_json)}")
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
end

def sqs_client
  $sqs_client ||= Aws::SQS::Client.new(
    region: 'us-west-2',
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  )
end

# WEBHOOK_URL = Secrets.instance.get_secret('discord-webhook-url')['DISCORD_WEBHOOK_URL']

def discord_webhook_client
  client ||= Discordrb::Webhooks::Client.new(url: WEBHOOK_URL)
end

def send_discord_webhook(msg)
  discord_webhook_client.execute do |builder|
    builder.add_embed do |embed|
      embed.title = msg
      embed.description = 'New IP for Direct Connect'
      embed.timestamp = Time.now
    end
  end
end
# def discord_bot_client
#   bot ||= Discordrb::Bot.new token: Secrets.instance.get_secret('DISCORD_BOT_TOKEN')
# end

# binding.pry;1

SQS_QUEUE_URL='https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_player_messages'

def poll_sqs
  while true
    puts "polling sqs with #{sqs_client}"
    res = $sqs_client.receive_message({
      queue_url: SQS_QUEUE_URL,
    })
    unless res.to_h[:messages].nil?
      message = res.to_h[:messages][0]
      send_discord_webhook(JSON.parse(message[:body])["public_ip"])
      $sqs_client.delete_message({
        queue_url: SQS_QUEUE_URL,
        receipt_handle: message[:receipt_handle]
      })
    end
    sleep 5
  end
end

#t = Thread.new { poll_sqs }

#bot.run
#t.join

while true
  puts 'running'
  sleep 5
end
