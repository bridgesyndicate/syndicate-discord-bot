require 'discord_access'

class SlashCmdHandler
  class Barr
    def self.init(bot)
      bot.application_command(:barr) do |event|
        puts "#{event.user.id}, #{event.user.username} using barr " +
             "command on #{event.options['ign']}"
        next unless is_moderator?(event.user.roles)

        status = SyndicateWebService.get_player_by_minecraft_name(event.options['ign'])
        if status.class == Net::HTTPOK
          puts "#{Time.now.inspect.to_s} status OK"
          discord_id = JSON.parse(status.body)['user']['discord_id']
          member = event.server.member(discord_id)
          member.add_role(
            DiscordAccess.get_banned_role(event.server.roles)
          )
          event.respond(content: "#{event.options['ign']} " +
                        format_discord_id_mention(discord_id) +
                        " Banned")
        else
          {"reason":"Syndicate cannot find this username"}
          event.respond(content: JSON.parse(status.body)['reason'])
        end
      end
    end
  end
end
