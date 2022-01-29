require 'scrims'
require 'discord_resolver'
require 'mock_elo_resolver'
require 'mock_discord_resolver'
require 'discord_notifier'

class SlashCmdHandler
  class Duel

    DUEL_CREATED = 'Your duel has been created'
    DUEL_FAILED_UNEQUAL_PARTY_SIZES = 'You cannot duel a team with a different party size'
    DUEL_REQUEST_CONFIRMATION = 'Your duel request has been sent.'
    DUEL_ERROR = 'Something went wrong.'

    def self.init(bot)
      bot.application_command(:duel) do |event|
        duel = Scrims::Duel.new($scrims_storage_rom)
        duel.discord_resolver = DiscordResolver.new(bot, event.server.id)
        duel.elo_resolver = MockEloResolver.new
        duel.notifier = Notifier.new(bot, event.server.id, duel.game_uuid)
        response = DUEL_CREATED
        begin
          duel.create_duel(event.user.id.to_s,
                           event.options['opponent'])
        rescue Scrims::Duel::PartySizesUnequal => e
          event.respond(content: DUEL_FAILED_UNEQUAL_PARTY_SIZES)
          return
        end

        status = SyndicateWebService.send_game_to_syndicate_web_service(duel.to_json)

        if status.class == Net::HTTPOK
          duel.notifier.notify(duel.from_discord_id, duel.to_discord_id_list)
          formatted_blue = format_discord_id_mention_list(duel.blue_party_discord_id_list)
          formatted_red = format_discord_id_mention_list(duel.red_party_discord_id_list)
          response = "#{DUEL_REQUEST_CONFIRMATION} #{formatted_blue} vs. #{formatted_red}"
        else
          puts "Could not send_game_to_syndicate_web_service. Status was: #{status}"
          response = DUEL_ERROR
        end
          event.respond(content: response)
      end

      bot.button(custom_id: /^duel_accept_uuid_/) do |event|
        uuid = event.interaction.button.custom_id.split('duel_accept_uuid_')[1]
        discord_id = event.user.id.to_s
        status = SyndicateWebService.accept_game_syndicate_web_service(uuid, discord_id)

        if status.class == Net::HTTPOK
          event.update_message(content: "Accepted duel #{uuid}")
        else
          event.respond(content: "Something went wrong.")
          puts status.inspect
          puts status.body
          puts status.to_hash.inspect
        end
      end
    end
  end
end
