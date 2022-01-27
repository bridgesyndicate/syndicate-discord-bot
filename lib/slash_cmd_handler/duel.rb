require 'scrims'

class SlashCmdHandler
  class Duel

    def self.init(bot)
      bot.application_command(:duel) do |event|
        begin
          duel = Duel.new($scrims_storage_rom)
          game_json = duel.duel(event.user.id,
                                event.options['opponent'])
          status = SyndicateWebService.send_game_to_syndicate_web_service(game_json)
        rescue
          # deal with exceptions
        end

        if status.class == Net::HTTPOK
          custom_id = "duel_accept_uuid_" + JSON.parse(game_json)['uuid']
          event.server.member(red_team_discord_ids.first).pm.send_embed() do |embed, view|
            embed.description = "Duel Request from <@#{event.user.id}>"
            view.row do |r|
              r.button(
                label: 'Accept',
                style: :primary,
                custom_id: custom_id
              )
            end
          end
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