#!/usr/bin/env ruby

# frozen_string_literal: true

require 'discordrb'

bot = Discordrb::Bot.new  token: 'ODU2MzY5NzY0NzI5NjE4NDMy.YNACfg.0EfzhPl44YdmsYvLl8RyTvVyHHs', 
                          log_mode: :debug

puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

$message_number = 0

bot.message do |event|
  $message_number += 1
  puts event.inspect
  
  event.respond "processed message #{$message_number}"
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
