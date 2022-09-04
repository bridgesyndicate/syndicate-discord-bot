require 'discord_access'
require 'user'

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
          user = User.new(discord_id: event.user.id.to_s)
          user.add_verified_role(bot)
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