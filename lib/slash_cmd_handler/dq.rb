require 'scrims'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Dequeue

    include Helpers

    attr_accessor :bot
    attr_accessor :queue

    def initialize(bot, queue)
      @bot = bot
      @queue = queue
    end

    def add_handlers
      bot.application_command(:dq) do |event|
        puts "Request to dequeue from #{event.user.id}, #{event.user.username}"

        if queue.dequeue_player(event.user.id) == 1
          event.respond(content: "#{event.user.username}(#{event.user.id}) has been removed from the queue.")
        else
          event.respond(content: "You are not in the queue.")
        end
      end
    end
  end
end