require 'slash_cmd_handler/party'
require 'slash_cmd_handler/duel'
require 'slash_cmd_handler/barr'

module SlashCmdHandler
  module Helpers

    def roles_for_member(discord_id)
      bot.server(DISCORD_SERVER_ID)
        .member(discord_id)
        .roles
    end

    def ensure_duel_roles(event, roles)
      error = :unverified_sender if !DiscordAccess.is_verified?(roles)
      error = :banned_sender if DiscordAccess.is_banned?(roles)
      error = :famous_recipient if DiscordAccess.is_famous?(roles)
      EmbedBuilder.send(:duel_request_sent,
                         event: event,
                         error: error) unless error.nil?
      error.nil?
    end

    def ensure_duel_accept_roles(event, roles)
      error = :unverified_recipient if !DiscordAccess.is_verified?(roles)
      error = :banned_recipient if DiscordAccess.is_banned?(roles)
      EmbedBuilder.update(:accept_duel_request,
                         event: event,
                         error: error) unless error.nil?
      error.nil?
    end
  end
end
