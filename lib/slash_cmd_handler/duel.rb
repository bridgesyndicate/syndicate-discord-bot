require 'scrims'
require 'discord_resolver'
require 'elo_resolver'
require 'mock_discord_resolver'
require 'discord_notifier'
require 'syndicate_embeds'

class SlashCmdHandler
  class Duel

    def self.init(bot)
      bot.application_command(:duel) do |event|
        puts "#{event.user.id}, #{event.user.username} using duel command"
        next unless ensure_verified_user(embed_builder, event)
        next unless ensure_verified_recipient(embed_builder, bot, event, event.options['opponent'])
        next unless ensure_ordinary_recipient(embed_builder, bot, event, event.options['opponent'], :duel_request_sent)

        duel = Scrims::Duel.new($scrims_storage_rom)
        duel.discord_resolver = DiscordResolver.new(bot)
        begin
          duel.create_duel(event.user.id.to_s,
                           event.options['opponent'])
        rescue Scrims::Duel::PartySizesUnequalError => e
        end
        discord_id_list = {red: duel.red_party_discord_id_list, blue: duel.blue_party_discord_id_list}
        EmbedBuilder.send(:duel_request_sent,
                           event: event,
                           error: e,
                           discord_id_list: discord_id_list)
        if e.nil?
          duel.notifier = DiscordNotifier.new(bot, embed_builder, duel.uuid)
          duel.notifier.notify(duel.from_discord_id, duel.to_discord_id_list, discord_id_list)
        end
      end

      bot.button(custom_id: /^duel_accept_uuid_/) do |event|
        event.update_message(content: 'Processing Duel...')
        puts "#{Time.now.inspect.to_s} duel accept button hit by #{event.user.id}"
        uuid = event.interaction.button.custom_id.split('duel_accept_uuid_')[1]
        acceptor_id = event.user.id.to_s
        duel = Scrims::Duel.new($scrims_storage_rom)
        duel.discord_resolver = DiscordResolver.new(bot)
        duel.elo_resolver = EloResolver.new
        begin
          duel.accept(uuid, acceptor_id)
        rescue Scrims::DoubleLockError => e
        rescue Scrims::Duel::ExpiredDuelError => e
        rescue Scrims::Duel::LockedPlayerError => e
        rescue Scrims::Duel::MissingDuelError => e
        rescue Scrims::Duel::InvalidAcceptorError => e
        end

        if e.nil?
          discord_id_list = {red: duel.red_party_discord_id_list, blue: duel.blue_party_discord_id_list}
          game_json = duel.to_json
          puts "game json: #{game_json}"
          status = SyndicateWebService
                    .send_game_to_syndicate_web_service(game_json)
        end

        if ( status.class == Net::HTTPOK || status.nil? )
          puts "status OK"
          EmbedBuilder.update(:accept_duel_request,
                               event: event,
                               error: e,
                               discord_id_list: discord_id_list)
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
