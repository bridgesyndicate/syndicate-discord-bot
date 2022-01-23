class Scrims
  class MemberRepo < ROM::Repository[:members]
    commands :create, update: :by_pk, delete: :by_pk

    def find_by_discord_id(discord_id)
      members.where(discord_id: discord_id)
        .combine(:parties)
    end
  end
end
