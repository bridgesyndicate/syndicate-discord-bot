require 'discord_access'
require 'time'
require 'user'

class AdminCmdHandler
  class Ban

    include SlashCmdHandler::Helpers

    attr_accessor :bot, :bot_command

    def initialize(bot, bot_command)
      @bot = bot
      @bot_command = bot_command
    end

    def add_handlers
      bot_command.command(:ban,
                          min_args: 1,
                          max_args: 1,
                          description: 'Bans a player via Minecraft IGN.',
                          usage: 'ban [ign]') do |event, ign|
        syn_logger "#{event.user.id}, #{event.user.username} using ban " +
                   "command on #{ign}"
        next unless ensure_admin(event, roles_for_member(event.user), :ban)
        status = SyndicateWebService.get_player_by_minecraft_name(ign)
        case status
          when Net::HTTPOK
            discord_id = JSON.parse(status.body)['user']['discord_id']
            ban_user(event, ign, discord_id)
          when Net::HTTPNotFound
            if JSON.parse(status.body)['reason'] == 'Mojang cannot find this username'
              event.respond("Mojang couldn't resolve Minecraft username: #{ign}")
            else
              event.respond("Syndicate couldn't resolve Minecraft username: #{ign}")
            end
          when Net::HTTPBadRequest, Net::HTTPForbidden
            event.respond("The IGN given was in an invalid format.")
          else
            event.respond("Something went wrong at " + Time.now.to_s)
            syn_logger status
        end

      end
      bot_command.run # note: bot must be restarted when taking away/giving admin role
    end

    def ban_user(event, ign, discord_id)
      user = User.new(discord_id: discord_id)
      minecraft_uuid = {minecraft_uuid: user.properties[:minecraft_uuid]}
      status = SyndicateWebService.ban_player_by_minecraft_uuid(minecraft_uuid)
      case status
        when Net::HTTPOK
          event.respond("Player #{ign} is now banned.")
        else
          puts status
          event.respond("no")
      end
    end
  end
end

#         next unless ensure_moderator(event, roles_for_member(event.user), :ban)
#         status = SyndicateWebService.get_player_by_minecraft_name(event.options['ign'])
#         if status.class == Net::HTTPOK
#           puts "#{Time.now.inspect.to_s} status OK"
#           discord_id = JSON.parse(status.body)['user']['discord_id']
#           member = bot.server(DISCORD_SERVER_ID).member(discord_id)
#           member.add_role(
#             DiscordAccess.get_banned_role(bot.server(DISCORD_SERVER_ID).roles)
#           )
#           leave = Scrims::Leave.new($rom)
#           begin
#             leave.leave(event.user.id.to_s)
#           rescue Scrims::Leave::MemberNotInPartyError => e
#           end
#           SyndicateEmbeds::Builder.send(:ban,
#                              event: event,
#                              discord_id_list: discord_id.to_s)
#           SyndicateEmbeds::Builder.send(:ban_acknowledge,
#                              channel: member.pm)
#         else
#           error = :syndicate_cant_find_user
#           if JSON.parse(status.body)['reason'] == 'Mojang cannot find this username'
#             error = :mojang_cant_find_user
#           end
#           SyndicateEmbeds::Builder.send(:ban,
#                              event: event,
#                              error: error)
#         end
