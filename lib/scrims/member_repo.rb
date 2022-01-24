class Scrims
  class MemberRepo < ROM::Repository[:members]
    commands :create, update: :by_pk, delete: :by_pk

    def get_party(discord_id)
      result = find_by_discord_id(discord_id)
      unless result.first.nil?
        party_uuid = result.first.parties.party_uuid
      end
    end

    def find_by_discord_id(discord_id)
      members.where(discord_id: discord_id)
        .combine(:parties)
    end
  end
end
