class Scrims
  class MemberRepo < ROM::Repository[:members]
    commands :create, update: :by_pk, delete: :by_pk

    def get_party(discord_id)
      result = find_by_discord_id(discord_id)
      unless result.nil?
        result.party_id
      end
    end

    def discord_id_in_party?(discord_id)
      members
        .where(discord_id: discord_id)
        .to_a
        .size == 1
    end

    def find_by_discord_id(discord_id)
      members.where(discord_id: discord_id)
        .first
    end

    def delete_by_discord_id(discord_id)
      members.where(discord_id: discord_id).delete
    end
  end
end
