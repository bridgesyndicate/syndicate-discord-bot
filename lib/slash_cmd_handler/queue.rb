require 'scrims'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Queue

    include Helpers

    attr_accessor :bot, :queue

    def initialize(bot, queue)
      @bot = bot
      @queue = queue
    end

    def add_handlers
      bot.application_command(:q) do |event|
        syn_logger "Request to queue from #{event.user.id}, #{event.user.username}"
        next unless ensure_queuer_roles(event, roles_for_member(event.user))

        if queue.member_repo.discord_id_in_party?(event.user.id)
          # queue party
        else
          # queue player
        
        queue_params = {
          discord_id: event.user.id,
          discord_username: event.user.username,
          queue_time: Time.now.to_i,
        }
        puts "queue_params for #{event.user.id} are #{queue_params}"

        begin
          queue.queue_player(queue_params)
          event.respond(content: "#{event.user.username} is queued. Type /dq to dequeue.")
        rescue Scrims::Queue::AlreadyQueuedError => e
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
