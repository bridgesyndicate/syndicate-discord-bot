require 'discord_access'
require 'time'
require 'user'

class AdminCmdHandler
  class BanUnban

    include SlashCmdHandler::Helpers

    attr_accessor :bot, :leave_repo, :queue, :server_id

    def initialize(bot)
      @bot = bot
      @leave_repo = Scrims::Leave.new($rom)
      @queue = Scrims::Queue.new($rom)
      @server_id = BotConfig.config.discord_guild_id
    end

    def add_handlers
      bot.application_command(:ban) do |event|
        ign = event.options['ign']
        syn_logger "#{event.user.id}, #{event.user.username} using ban command on #{ign}"
        next unless ensure_admin(event, roles_for_member(event.user))
        event.respond(content: 'Processing...')
        resolve_player_to_ban_or_unban(event, ign, :ban)
      end

      bot.application_command(:unban) do |event|
        ign = event.options['ign']
        syn_logger "#{event.user.id}, #{event.user.username} using unban command on #{ign}"
        next unless ensure_admin(event, roles_for_member(event.user))
        event.respond(content: 'Processing...')
        resolve_player_to_ban_or_unban(event, ign, :unban)
      end
    end

    def resolve_player_to_ban_or_unban(event, ign, type)
      status = SyndicateWebService.new.get_player_by_minecraft_name(ign)
      case status
        when Net::HTTPOK
          discord_id = JSON.parse(status.body)['user']['discord_id']
          ban_or_unban_user(event, ign, discord_id, type)
        when Net::HTTPNotFound
          if JSON.parse(status.body)['reason'] == 'Mojang cannot find this username'
            event.interaction.edit_response(content: "Mojang couldn't resolve Minecraft username: #{ign}")
          else
            event.interaction.edit_response(content: "Syndicate couldn't resolve Minecraft username: #{ign}")
          end
        when Net::HTTPBadRequest, Net::HTTPForbidden
          event.interaction.edit_response(content: "The IGN given was in an invalid format.")
        else
          event.interaction.edit_response(content: "Something went wrong at " + Time.now.to_s)
          syn_logger status
      end
    end

    def ban_or_unban_user(event, ign, discord_id, type)
      user = User.new(discord_id: discord_id)
      minecraft_uuid = user.properties[:minecraft_uuid]
      if type == :ban
        ban_user(event, minecraft_uuid, ign, discord_id)
      elsif type == :unban
        unban_user(event, minecraft_uuid, ign, discord_id)
      else
        raise 'unhandled type (must be :ban or :unban)'
      end
    end

    def ban_user(event, minecraft_uuid, ign, discord_id)
      status = SyndicateWebService.new.ban_user_by_minecraft_uuid_post(minecraft_uuid)
      case status
        when Net::HTTPOK
          event.interaction.edit_response(content: "Player #{ign} is now banned.")
          user = User.new(discord_id: discord_id)
          user.ban
          if queue.member_repo.discord_id_in_party?(discord_id)
            party_id = queue.member_repo.get_party(discord_id)
            queue.dequeue_party(party_id)
          else
            queue.dequeue_player(discord_id)
          end
          begin
            leave_repo.leave(discord_id.to_s)
          rescue Scrims::Leave::MemberNotInPartyError => e
          end
          user.add_banned_role(bot)
          member = bot.server(server_id).member(discord_id)
          SyndicateEmbeds::Builder.send(:ban_acknowledge,
                                        channel: member.pm) unless member.nil?
        when Net::HTTPBadGateway
          event.interaction.edit_response(content: "Error: player #{ign} is already banned.")
        else
          event.interaction.edit_response(content: "Something went wrong at " + Time.now.to_s)
          puts status
      end
    end

    def unban_user(event, minecraft_uuid, ign, discord_id)
      status = SyndicateWebService.new.unban_user_by_minecraft_uuid_delete(minecraft_uuid)
      case status
        when Net::HTTPOK
          event.interaction.edit_response(content: "Player #{ign} is now unbanned.")
          user = User.new(discord_id: discord_id)
          user.unban
          user.remove_banned_role(bot)
          member = bot.server(server_id).member(discord_id)
          SyndicateEmbeds::Builder.send(:unban_acknowledge,
                                        channel: member.pm) unless member.nil?
        when Net::HTTPBadGateway
          event.interaction.edit_response(content: "Error: player #{ign} is already unbanned.")
        else
          event.interaction.edit_response(content: "Something went wrong at " + Time.now.to_s)
          puts status
      end
    end

  end
end
