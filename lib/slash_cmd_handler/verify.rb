require 'discord_access'

class SlashCmdHandler
  class Verify

    def self.init(bot)
      bot.application_command(:verify) do |event|
        code = event.options['code']
        response = SyndicateWebService.register_with_syndicate_web_service(code, event.user.id)
        case response
        when Net::HTTPBadGateway
          error = :bad_status
          puts "error. response is #{response}"
        when Net::HTTPBadRequest
          error = :invalid_format
        when Net::HTTPForbidden
          error = :invalid_format
        when Net::HTTPNotFound
          error = :not_found
        when Net::HTTPOK
          bot.server(DISCORD_SERVER_ID).member(event.user).add_role(
                     DiscordAccess.get_verified_role(
                     bot.server(DISCORD_SERVER_ID).roles))
        else
          error = :bad_status
        end
        SyndicateEmbeds::Builder.send(:verify,
                                 event: event,
                                 error: error)
      end
    end

  end
end