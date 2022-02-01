class Lock

  class LockedPlayer < StandardError
    def initialize(n)
      msg="One or more players are locked"
      super
    end
  end

  attr_accessor :lock_repo

  def initialize(rom)
    @lock_repo = Scrims::LockRepo.new(rom)
  end

  def lock_player(discord_id)
    lock_repo.transaction do |t|
    lock_repo.create({ discord_id: discord_id,
                       created_at: Time.now.utc.iso8601
                     }
    return discord_id
    end
  end
end

