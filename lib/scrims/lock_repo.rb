class Scrims
  class LockRepo < ROM::Repository[:locks]
    commands :create, update: :by_pk, delete: :by_pk

    def by_pk(discord_id)
      locks.by_pk(discord_id)
    end

    def locked?(discord_id)
      by_pk(discord_id)
        .count == 1
    end

    def find_by_discord_id(discord_id)
    locks.where(discord_id: discord_id)
            .first rescue nil
    end

    def unlock_player(discord_id)
      locks.where(discord_id: discord_id).delete
    end

  end
end
