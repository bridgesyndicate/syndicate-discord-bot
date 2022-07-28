require 'scrims'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Queue

    include Helpers

    attr_accessor :bot
    attr_accessor :queue

    def initialize(bot, queue)
      @bot = bot
      @queue = queue
    end

    def add_handlers
      bot.application_command(:q) do |event|
        puts "Request to queue from #{event.user.id}, #{event.user.username}"

        #next unless ensure_verified_user(event)

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
          event.respond(content: "#{event.user.username} is queued. Type /dq to dequeue.")
        else
          event.respond(content: "You are already queued")
        end
        DelayedWorker.new(Scrims::MAX_QUEUE_TIME) do
          GameMaker.from_match(queue.process_queue)
        end.run
        GameMaker.from_match(queue.process_queue)
      end
    end
  end
end