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

    def ensure_able_to_play(event, discord_id)
      user = User.new(discord_id)
      error = 'You must be verified to use this command.' if !user.is_verified?
      error = 'You are banned.' if user.is_banned?
      event.respond(content: error) unless error.nil?
      error.nil?
    end

  end
end
