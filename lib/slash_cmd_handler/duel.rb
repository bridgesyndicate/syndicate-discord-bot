require 'scrims'
require 'discord_resolver'
require 'mock_elo_resolver'
require 'mock_discord_resolver'

class SlashCmdHandler
  class Duel

    DUEL_CREATED = 'Your duel has been created'
    DUEL_FAILED_UNEQUAL_PARTY_SIZES = 'You cannot duel a team with a different party size'

    def self.init(bot)
      bot.application_command(:duel) do |event|
        duel = Scrims::Duel.new($scrims_storage_rom)
        duel.discord_resolver = DiscordResolver.new(bot, event.server.id)
        duel.elo_resolver = MockEloResolver.new
        duel.notify_opponents = Notifier.new(bot, event)
        response = DUEL_CREATED
        begin
          duel.create_duel(event.user.id,
                           event.options['opponent'])
        rescue Scrims::Duel::PartySizesUnequal => e
          event.respond(content: DUEL_FAILED_UNEQUAL_PARTY_SIZES)
          return
        end

        status = SyndicateWebService.send_game_to_syndicate_web_service(duel.to_json)

        if status.class == Net::HTTPOK
          custom_id = "duel_accept_uuid_" + JSON.parse(duel.to_json)['uuid']
          duel.notify_opponents(duel.red_party, custom_id)

          event.respond(
            content: "Your duel request has been sent. #{blue_team_discord_names.join(', ')} vs. #{red_team_discord_names.join(', ')}"
          )
        else
          puts "Could not send_game_to_syndicate_web_service. Status was: #{status}"
          event.respond(content: "Something went wrong")
        end
      end
    end
  end
end
