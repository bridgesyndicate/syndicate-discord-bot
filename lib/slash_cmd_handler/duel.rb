require 'scrims'
require 'discord_resolver'
require 'elo_resolver'
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
        puts "#{event.user.id}, #{event.user.username} using duel command"
        next unless ensure_verified_user(event)
        next unless ensure_verified_acceptor(bot, event, event.options['opponent'])

        duel = Scrims::Duel.new($scrims_storage_rom)
        duel.discord_resolver = DiscordResolver.new(bot)
        begin
          duel.create_duel(event.user.id.to_s,
                           event.options['opponent'])
        rescue Scrims::Duel::PartySizesUnequalError => e
          event.respond(content: DUEL_FAILED_UNEQUAL_PARTY_SIZES)
          next
        end
        response = DUEL_CREATED
        duel.notifier = DiscordNotifier.new(bot, duel.uuid)
        duel.notifier.notify(duel.from_discord_id, duel.to_discord_id_list)
        formatted_blue = format_discord_id_mention_list(duel.blue_party_discord_id_list)
        formatted_red = format_discord_id_mention_list(duel.red_party_discord_id_list)
        response = "#{DUEL_REQUEST_CONFIRMATION} #{formatted_blue} vs. #{formatted_red}"
        event.respond(content: response)
      end

      bot.button(custom_id: /^duel_accept_uuid_/) do |event|
        event.update_message(content: 'Processing Duel...')
        puts "#{Time.now.inspect.to_s} duel accept button hit by #{event.user.id}"
        uuid = event.interaction.button.custom_id.split('duel_accept_uuid_')[1]
        discord_id = event.user.id.to_s
        duel = Scrims::Duel.new($scrims_storage_rom)
        duel.discord_resolver = DiscordResolver.new(bot)
        duel.elo_resolver = EloResolver.new
        begin
          duel.accept(uuid, discord_id)
        rescue Scrims::DoubleLockError => e
          event.interaction.edit_response(content: 'This duel has duplicate players.')
          next
        rescue Scrims::Duel::ExpiredDuelError => e
          event.interaction.edit_response(content: 'This duel has expired.')
          next
        rescue Scrims::Duel::LockedPlayerError => e
          event.interaction.edit_response(content: 'A player from this duel is in another game.')
          next
        rescue Scrims::Duel::MissingDuelError => e
          event.interaction.edit_response(content: 'No such duel exists.')
          next
        rescue Scrims::Duel::InvalidAcceptorError => e
          event.interaction.edit_response(content: 'You are not a valid acceptor of this duel.')
          next
        end

        game_json = duel.to_json
        puts "#{Time.now.inspect.to_s} game json: #{game_json}"
        status = SyndicateWebService
                   .send_game_to_syndicate_web_service(game_json)
        if status.class == Net::HTTPOK
          puts "#{Time.now.inspect.to_s} status OK"
          event.interaction.edit_response(content: "Duel Accepted!")
        else
          event.interaction.edit_response(content: "Something went wrong.")
          puts status.inspect
          puts status.body
          puts status.to_hash.inspect
        end
      end
    end
  end
end
