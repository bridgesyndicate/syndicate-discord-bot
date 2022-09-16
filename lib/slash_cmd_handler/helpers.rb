class SlashCmdHandler
  module Helpers

    def roles_for_member(discord_id)
      bot.server(DISCORD_SERVER_ID)
        .member(discord_id)
        .roles
    end

    def ensure_moderator(event, sender_roles, type)
      error = :insufficient_permission if !DiscordAccess.is_moderator?(sender_roles)
      SyndicateEmbeds::Builder.send(type,
                        event: event,
                        error: error) unless error.nil?
      error.nil?
    end

    def ensure_admin(event, sender_roles)
      error = :insufficient_permission if !DiscordAccess.is_admin?(sender_roles)
      event.respond(content: 'You must be an admin to use this command.') unless error.nil?
      error.nil?
    end

    def ensure_able_to_play(event, discord_id, command_or_button, you_or_they)
      begin
        user = User.new(discord_id: discord_id)
      rescue User::UnregisteredUser => e
        if command_or_button == 'command'
          event.respond(content: you_or_they + ' must be verified to use this command.')
        elsif command_or_button == 'button'
          event.interaction.edit_response(content: you_or_they + ' must be verified to accept this invite.')
        end
      end

      if user.is_banned?
        e = :banned
        if command_or_button == 'command'
          event.respond(content: you_or_they + ' are banned.')
        elsif command_or_button == 'button'
          event.interaction.edit_response(content: you_or_they + ' are banned.')
        end
      end
      e.nil?
    end

  end
end
