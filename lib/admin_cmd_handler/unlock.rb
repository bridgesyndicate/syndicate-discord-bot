require 'discord_access'
require 'time'
require 'user'

class AdminCmdHandler
  class Unlock

    include SlashCmdHandler::Helpers

    attr_accessor :bot, :lock_repo

    def initialize(bot)
      @bot = bot
      @lock_repo = Scrims::Locks.new($rom)
    end

    def add_handlers
      bot.application_command(:unlock) do |event|
        discord_id = event.options['discord_id']
        syn_logger "#{event.user.id}, #{event.user.username} using unlock command on #{discord_id}"
        next unless ensure_admin(event, roles_for_member(event.user))
        lock_repo.unlock(discord_id)
        event.respond(content: "Unlocked discord id: #{discord_id}")
      end
    end
  end
end