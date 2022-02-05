class Scrims
  class DoubleLockError < StandardError
  end

  class Locks < ROM::Repository[:locks]
    commands :create

    def now
      Time.now.utc
    end

    def locked?(discord_id)
      now1 = now
      locks
        .where(discord_id: discord_id)
        .where{ (expires_at > now1 ) } # no idea why now does not work
        .count > 0
    end

    def unlock(discord_ids)
      now1 = now
      locks
        .where(discord_id: discord_ids)
        .update(expires_at: now1)
    end

    def lock(discord_id, duration_seconds)
      expires_at = now + duration_seconds
      begin
        self.create({ discord_id: discord_id,
                      expires_at: expires_at,
                      created_at: now
                    }).id
      rescue ROM::SQL::UniqueConstraintError => e
        raise DoubleLockError
      end
    end
  end
end
