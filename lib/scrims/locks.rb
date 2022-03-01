class Scrims
  class DoubleLockError < StandardError
  end

  class Locks < ROM::Repository[:locks]
    commands :create

    def now
      Time.now
    end

    def locked?(discord_id)
      now1 = now
      locks
        .where(discord_id: discord_id)
        .where{ (expires_at > now1 ) } # no idea why now does not work. oh might be a reserved word
        .count > 0
    end

    def unlock(discord_ids)
      now1 = now
      locks
        .where(discord_id: discord_ids)
        .delete
    end

    def lock(discord_id, duration_seconds)
      expires_at = now + duration_seconds
      locks.transaction do |t|
        existing = locks
          .where(discord_id: discord_id)
        if existing.count > 0
          if existing.first.expires_at < now
            existing
              .update(created_at: now,
                      expires_at: expires_at)
          else
            raise DoubleLockError
          end
        else
          self.create({ discord_id: discord_id,
                        expires_at: expires_at,
                        created_at: now
                      }).id
        end
      end
    end
  end
end
