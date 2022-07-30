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

        next unless ensure_queuer_roles(event, roles_for_member(event.user))

        response = SyndicateWebService.get_user_record(event.user.id)

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
        rescue Scrims::Queue::AlreadyQueuedError => e
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