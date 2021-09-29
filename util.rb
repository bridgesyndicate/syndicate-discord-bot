#!/usr/bin/env ruby

# frozen_string_literal: true
require 'bundler'
require 'time'
Bundler.require
require 'discordrb'
require 'discordrb/webhooks'

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'syndicate_web_service'

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] || 'production'

blue_team_discord_ids = ['417766998471213061']
red_team_discord_ids = ['523316151044931604']
blue_team_discord_names = ['kiier']
red_team_discord_names = ['vice9']
goals =  1
length = 120
game_json = SyndicateWebService.make_game_json(
  blue_team_discord_ids: blue_team_discord_ids,
  red_team_discord_ids: red_team_discord_ids,
  blue_team_discord_names: blue_team_discord_names,
  red_team_discord_names: red_team_discord_names,
  goals: goals,
  length: length
)

status = SyndicateWebService.send_game_to_syndicate_web_service(game_json)

unless status.class == Net::HTTPOK
  puts status.class
  puts status.body
end

status = SyndicateWebService
           .accept_game_syndicate_web_service(JSON.parse(game_json)['uuid'],
                                              '523316151044931604')

unless status.class == Net::HTTPOK
  puts status.class
  puts status.body
end
