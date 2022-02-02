class LockRepo < ROM::Repository[:locks]
  commands :create, update: :by_pk, delete: :by_pk

  def by_pk(discord_id)
    locks.by_pk(discord_id)
  end

  def is_locked?(discord_id)
    by_pk(discord_id)
      .count == 1
  end

  def lock(discord_id, duration)
    now = Time.now.to_i
    expires_at = now + (duration * 60)
    locks.create({ discord_id: discord_id,
                   expires_at: expires_at,
                   created_at: now
                 })
  end

end
