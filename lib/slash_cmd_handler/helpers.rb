class SlashCmdHandler
  module Helpers

    def roles_for_member(discord_id)
      bot.server(DISCORD_SERVER_ID)
        .member(discord_id)
        .roles
    end

    def ensure_sender_roles(event, sender_roles, recipient_roles, type)
      error = :unverified_sender if !DiscordAccess.is_verified?(sender_roles)
      error = :banned_sender if DiscordAccess.is_banned?(sender_roles)
      error = :famous_recipient if DiscordAccess.is_famous?(recipient_roles) && !DiscordAccess.is_famous?(sender_roles)
      EmbedBuilder.send(type,
                        event: event,
                        error: error) unless error.nil?
      error.nil?
    end

    def ensure_recipient_roles(event, recipient_roles, type)
      error = :unverified_recipient if !DiscordAccess.is_verified?(recipient_roles)
      error = :banned_recipient if DiscordAccess.is_banned?(recipient_roles) && !DiscordAccess.is_famous?(sender_roles)
      EmbedBuilder.update(type,
                          event: event,
                          error: error) unless error.nil?
      error.nil?
    end

  end
end
