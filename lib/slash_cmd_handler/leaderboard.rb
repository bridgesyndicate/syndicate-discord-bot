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

    def current_season
      Object.const_get(BotConfig.config.season_klass).new.season_name
    end

    def add_handlers
      bot.application_command(:lb) do |event|
        syn_logger "#{event.user.id}, #{event.user.username} using leaderboard command"
        next unless ensure_able_to_play(bot, event, event.user.id.to_s, 'command', 'You')
        season = event.options['season'] || current_season
        begin
          lb_formatted = leaderboard.format_lb(event.options['sort'] || DEFAULT_SORTING_TYPE,
                                               event.options['page'] || DEFAULT_PAGE_NUMBER,
                                               season,
                                               event.user.id)
        rescue Scrims::Leaderboard::PageOutOfBoundsError => e
        end
        lb_title = "Leaderboard for `#{season}`:"
        SyndicateEmbeds::Builder.send(:leaderboard,
                                       event: event,
                                       error: e,
                                       forced_description: lb_formatted,
                                       forced_title: lb_title)
      end
    end

  end
end
