#!/usr/bin/env ruby

# frozen_string_literal: true

require 'discordrb'
require 'aws-sigv4'

WAITING_ROOM_ID = 855996952348327950
BASE_URL = 'https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/game'

bot = Discordrb::Bot.new token: 'ODU2MzY5NzY0NzI5NjE4NDMy.YNACfg.0EfzhPl44YdmsYvLl8RyTvVyHHs'

def make_game_json(red, blue)
  match = {
    blueTeam: blue.split(/,\s*/),
    redTeam:  red.split(/,\s*/),
    requiredPlayers: blue.split(/,\s*/).size + red.split(/,\s*/).size,
    goalsToWin: 3,
    gameLengthInSeconds: 300
  }
  JSON.pretty_generate(match)
end


def send_game_to_syndicate_web_service(game_json)
  signer = Aws::Sigv4::Signer.new(
                                  service: 'execute-api',
                                  region: 'us-west-2',
                                  access_key_id: 'AKIAYVJYQ7DNBK4E3CVM',
                                  secret_access_key: 'foo'
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
  https.request(req).body
end

bot.application_command(:q) do |event|
  red = event.options['red']
  blue = event.options['blue']
  game_json = make_game_json(red, blue)
  event.respond(content: "your game is #{red} vs. #{blue} with json of #{game_json} #{send_game_to_syndicate_web_service(game_json)}")
end

$message_number = 0

bot.message do |event|
  $message_number += 1
  puts event.inspect

  event.respond "processed message #{$message_number}"
  unless event.user.voice_channel.nil?
    unless event.user.voice_channel.id == WAITING_ROOM_ID
      event.respond "you are not in the Waiting ROom"
      event.respond "your voice channel is: #{event.user.voice_channel.name}"
      event.respond "your voice channel is: #{event.user.voice_channel.id}"
    else
      event.respond 'you are in the waitingdifjn rooosdfosdfm'
    end
  else
    event.respond 'you must be in a voice channel'
  end
end

bot.run
