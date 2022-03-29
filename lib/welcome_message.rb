require 'bot_config'

class WelcomeMessage

    def self.init(bot)

      admin_discord_id = BotConfig.config.admin_discord_id

      bot.message(from: admin_discord_id, content: "create welcome message here") do |event|
        SyndicateEmbeds::Builder.send(:welcome_message,
                                      event: event,
                                      custom_id: "verify_button")
      end

      bot.button(custom_id: "verify_button") do |event|
        response = "Check your DMs."
        begin
          SyndicateEmbeds::Builder.send(:how_to_verify,
                                        channel: event.user.pm)
        rescue Discordrb::Errors::NoPermission => e
          response = "Failed. You must allow direct messages for this server to verify and play."
        end
        event.respond(content: response, ephemeral: true)
      end

    end

end