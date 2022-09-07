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

discord_ids = %w/942094212608979024 240177490906054658 246107858712788993/
ret = SyndicateWebService.new.user_by_discord_id_post(discord_ids)
STDERR.puts ret.class
binding.pry;1
puts ret.body

