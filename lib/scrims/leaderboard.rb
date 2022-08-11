class Scrims
  class Leaderboard

    class PageOutOfBoundsError < StandardError
    end

    INDEXES_PER_PAGE = 10
    SEPARATOR = "\n------------------------------\n"
    SPACER = " • "

    attr_accessor :leaderboard_repo

    def initialize(rom)
      @leaderboard_repo = Scrims::Storage::Leaderboard.new(rom)
    end

    def format_lb(type, page, season, requester_discord_id)
      sorted_lb = get_sorted_lb(type, season)
      starting_idx = get_starting_idx_from_page(sorted_lb, page)
      formatted_lb = sorted_lb.each_with_index.map do |leader, idx|
        "#{idx+1}. #{format_discord_id_mention(leader.discord_id)}" + SPACER + get_desired_statistic(leader, type)
      end[starting_idx, INDEXES_PER_PAGE].join("\n")
      formatted_lb.concat(requester_position(sorted_lb, type, requester_discord_id))
    end

    def get_sorted_lb(type, season)
      case type
        when 'elo'
          sorted_lb = leaderboard_repo.sort_by_elo
        when 'wins'
          sorted_lb = leaderboard_repo.sort_by_wins
        when 'losses'
          sorted_lb = leaderboard_repo.sort_by_losses
        when 'ties'
          sorted_lb = leaderboard_repo.sort_by_ties
        else
          puts "Invalid sort type: #{type}"
      end
      sorted_lb = sorted_lb.select{|entries| entries[:season] == season}
    end

    def get_starting_idx_from_page(sorted_lb, page)
      last_page = sorted_lb.count / 10 + 1
      if page.abs() > last_page
        raise Scrims::Leaderboard::PageOutOfBoundsError
      else
        starting_idx = (page-1) * 10
      end
    end

    def requester_position(sorted_lb, type, requester_discord_id)
      requester = sorted_lb.select{|entry| entry[:discord_id] == requester_discord_id}.first
      if requester.nil?
        ''
      else
        SEPARATOR +
        (sorted_lb.find_index(requester) + 1).to_s +
        '. ' +
        format_discord_id_mention(requester[:discord_id].to_s) +
        SPACER +
        get_desired_statistic(requester, type)
      end
    end

    def get_desired_statistic(key, type)
      (type == 'elo' ? "#{key.elo}" : '') +\
      (type == 'wins' ? "#{key.wins}" : '') +\
      (type == 'losses' ? "#{key.losses}" : '') +\
      (type == 'ties' ? "#{key.ties}" : '')
    end

  end
end
