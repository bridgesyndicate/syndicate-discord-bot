require 'discord_access'

class SlashCmdHandler
  class Barr

    include Helpers

        attr_accessor :bot

    def initialize(bot)
      @bot = bot
    end

    def add_handlers
      bot.application_command(:barr) do |event|
        puts "#{event.user.id}, #{event.user.username} using barr " +
             "command on #{event.options['ign']}"

        next unless ensure_moderator(event, roles_for_member(event.user), :barr)
        status = SyndicateWebService.new.get_player_by_minecraft_name(event.options['ign'])
        if status.class == Net::HTTPOK
          puts "#{Time.now.inspect.to_s} status OK"
          discord_id = JSON.parse(status.body)['user']['discord_id']
          member = bot.server(DISCORD_SERVER_ID).member(discord_id)
          member.add_role(
            DiscordAccess.get_banned_role(bot.server(DISCORD_SERVER_ID).roles)
          )
          leave = Scrims::Leave.new($rom)
          begin
            leave.leave(event.user.id.to_s)
          rescue Scrims::Leave::MemberNotInPartyError => e
          end
          SyndicateEmbeds::Builder.send(:barr,
                             event: event,
                             discord_id_list: discord_id.to_s)
          SyndicateEmbeds::Builder.send(:barr_acknowledge,
                             channel: member.pm)
        else
          error = :syndicate_cant_find_user
          if JSON.parse(status.body)['reason'] == 'Mojang cannot find this username'
            error = :mojang_cant_find_user
          end
          SyndicateEmbeds::Builder.send(:barr,
                             event: event,
                             error: error)
        end
      end
    end
  end
end
