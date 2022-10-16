# Seasons are from Friday at 11 am Mountain time to Sunday at 11:pm
# What is mountain time? It's a time in Colorado. What is Colarado?
# It is a place where Aspen is. Is that where they have the best
# snow? No, that's Utah. Is that where the highest mountain in the
# USA is? No, that California. Oh.

require 'tzinfo'

class Season
  SEASON_TZ = 'US/Mountain'
  COMPETITION_DAYS=%w/Friday Saturday Sunday/
  START_DAY = COMPETITION_DAYS.first
  END_DAY = COMPETITION_DAYS.last
  START_TIME = 11
  END_TIME = 23
  SEASON_ONE_START='Fri Oct 07 11:00:00 MDT 2022'
  ONE_WEEK_IN_SECONDS = 60 * 60 * 24 * 7

  attr_accessor :tz

  def initialize
    @tz = TZInfo::Timezone.get(SEASON_TZ)
  end

  def daynames
    Date::DAYNAMES
  end

  def day
    daynames[now.wday]
  end

  def now
    tz.to_local(Time.now)
  end

  def is_right_day?
    COMPETITION_DAYS.include?(day)
  end

  def is_late_first_day?
    day == COMPETITION_DAYS.first and
      now.hour > 10
  end

  def is_early_last_day?
    day == COMPETITION_DAYS.last and
      now.hour < 23
  end

  def is_middle_day?
    day == COMPETITION_DAYS[1]
  end

  def is_in_time_window?
    is_middle_day? or
      is_late_first_day? or
      is_early_last_day?
  end

  def is_in_season?
    is_right_day? and
      is_in_time_window?
  end

  def weeks_since_season_one
    ((now - Time.parse(SEASON_ONE_START)) / ONE_WEEK_IN_SECONDS).floor
  end

  def season_number
    weeks_since_season_one + 1
  end

  def season_name
    prefix = is_in_season? ? 'season' : 'preseason'
    if prefix == 'season'
      prefix + season_number.to_s
    else
      prefix + (season_number + 1).to_s
    end
  end
end

class MockSeason
  def season_name
    'test1'
  end
end
