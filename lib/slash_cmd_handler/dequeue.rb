require 'scrims'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Dequeue

    include Helpers

    attr_accessor :bot, :queue, :member_repo, :party_repo, :lock_repo

    def initialize(bot, queue)
      @bot = bot
      @queue = queue
      @member_repo = Scrims::MemberRepo.new($rom)
      @party_repo = Scrims::Storage::Party.new($rom)
      @lock_repo = Scrims::Locks.new($rom)
    end

    def add_handlers
      bot.application_command(:dq) do |event|
        puts "Request to dequeue from #{event.user.id}, #{event.user.username}"
        discord_id = event.user.id.to_s
        if queue.member_repo.discord_id_in_party?(discord_id)
          party_id = member_repo.get_party(discord_id)
          if queue.dequeue_party(party_id) >= 1
            party_repo.with_members(party_id).first.members.each do |member|
              lock_repo.unlock(member[:discord_id])
            end
            event.respond(content: "#{event.user.username}'s party has been removed from the queue.")
          else
            event.respond(content: "Your party is not queued.")
          end
        else
          if queue.dequeue_player(discord_id) >= 1
            lock_repo.unlock(discord_id.split)
            event.respond(content: "#{event.user.username} has been removed from the queue.")
          else
            event.respond(content: "You are not queued.")
          end
        end
      end
    end
  end
end