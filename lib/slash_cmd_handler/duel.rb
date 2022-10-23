require 'scrims'
require 'discord_resolver'
require 'elo_resolver'
require 'mock_discord_resolver'
require 'discord_notifier'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Duel

    include Helpers

    attr_accessor :bot

    def initialize(bot)
      @bot = bot
    end

    def add_handlers
      bot.application_command(:duel) do |event|
        puts "#{event.user.id}, #{event.user.username} using duel command"
        duel_target = event.options['opponent']
        next unless ensure_able_to_play(bot, event, event.user.id.to_s, 'command', 'You')

        duel = Scrims::Duel.new($rom)
        duel.discord_resolver = DiscordResolver.new(bot)
        begin
          duel.create_duel(event.user.id.to_s,
                           duel_target.to_s)
          discord_id_list = { red: duel.red_party_discord_id_list,
                              blue: duel.blue_party_discord_id_list
                            }
        rescue Scrims::Duel::PartySizesUnequalError => e
        end
        SyndicateEmbeds::Builder.send(:duel_request_sent,
                           event: event,
                           error: e,
                           discord_id_list: discord_id_list)
        if e.nil?
          duel.notifier = DiscordNotifier.new(bot, duel.uuid)
          duel.notifier.notify(duel.from_discord_id,
                               duel.to_discord_id_list,
                               discord_id_list)
        end
      end

      bot.button(custom_id: /^duel_accept_uuid_/) do |event|
        event.update_message(content: 'Processing Duel...')
        syn_logger "#{Time.now.inspect.to_s} duel accept button hit by #{event.user.id}"
        uuid = event.interaction.button.custom_id.split('duel_accept_uuid_')[1]
        next unless ensure_able_to_play(bot, event, event.user.id.to_s, 'button', 'You')

        duel = Scrims::Duel.new($rom)
        duel.discord_resolver = DiscordResolver.new(bot)
        duel.elo_resolver = EloResolver.new
        begin
          duel.accept(uuid, event.user.id.to_s)
        rescue Scrims::DoubleLockError => e
        rescue Scrims::Duel::ExpiredDuelError => e
        rescue Scrims::Duel::LockedPlayerError => e
        rescue Scrims::Duel::MemberInQueueError => e
        rescue Scrims::Duel::MissingDuelError => e
        rescue Scrims::Duel::InvalidAcceptorError => e
        else
          discord_id_list = { red: duel.red_party_discord_id_list,
                              blue: duel.blue_party_discord_id_list
                            }
          game_json = duel.to_json
          syn_logger "game json: #{game_json}"
          status = SyndicateWebService.new.send_game_to_syndicate_web_service(game_json)
          syn_logger "Sent game to web service: #{status.inspect}"
          e = :bad_status unless status.class == Net::HTTPOK
        end
        syn_logger "Error making game: #{e}" unless e.nil?
        SyndicateEmbeds::Builder.update(:accept_duel_request,
                                       event: event,
                                       error: e,
                                       discord_id_list: discord_id_list)
      end
    end
  end
end
