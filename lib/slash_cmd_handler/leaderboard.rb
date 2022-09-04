require 'scrims'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Leaderboard

    DEFAULT_SORTING_TYPE = 'elo'
    DEFAULT_PAGE_NUMBER = 1

    include Helpers

    attr_accessor :bot, :leaderboard

    def initialize(bot, leaderboard)
      @bot = bot
      @leaderboard = leaderboard
    end

    def add_handlers
      bot.application_command(:lb) do |event|
        syn_logger "#{event.user.id}, #{event.user.username} using leaderboard command"
        next unless ensure_able_to_play(event, event.user.id.to_s, 'command')
        begin
          lb_formatted = leaderboard.format_lb(event.options['sort'] || DEFAULT_SORTING_TYPE,
                                               event.options['page'] || DEFAULT_PAGE_NUMBER,
                                               BotConfig.config.current_season,
                                               event.user.id)
        rescue Scrims::Leaderboard::PageOutOfBoundsError => e
        end
        SyndicateEmbeds::Builder.send(:leaderboard,
                                       event: event,
                                       error: e,
                                       forced_description: lb_formatted)
      end
    end

  end
end