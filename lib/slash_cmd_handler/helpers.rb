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

    def ensure_admin(event, sender_roles, type)
      error = :insufficient_permission if !DiscordAccess.is_admin?(sender_roles)
      error.nil?
    end

    def ensure_able_to_play(event, discord_id, command_or_button)
      begin
        user = User.new(discord_id: discord_id)
      rescue User::UnregisteredUser => e
        if command_or_button == 'command'
          event.respond(content: 'You must be verified to use this command.')
        elsif command_or_button == 'button'
          event.interaction.edit_response(content: 'You must be verified to accept this invite.')
        end
      end
      e.nil?
    end

  end
end
