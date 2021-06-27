#!/usr/bin/env ruby

# frozen_string_literal: true

require 'discordrb'

bot = Discordrb::Bot.new token: 'ODU2MzY5NzY0NzI5NjE4NDMy.YNACfg.0EfzhPl44YdmsYvLl8RyTvVyHHs'

bot.application_command(:q) do |event|
  mode = event.options['gamemode']
  event.respond(content: "your gamemode was #{mode}")
  # event.send_message(content: 'https://pyxis.nymag.com/v1/imgs/09c/923/65324bb3906b6865f904a72f8f8a908541-16-spongebob-explainer.rsquare.w700.jpg')
end
  

$message_number = 0

bot.message do |event|
  $message_number += 1
  puts event.inspect
  
  event.respond "processed message #{$message_number}"
end

bot.run
