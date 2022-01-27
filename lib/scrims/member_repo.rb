class Scrims
  class MemberRepo < ROM::Repository[:members]
    commands :create, update: :by_pk, delete: :by_pk

    def get_party(discord_id)
      result = find_by_discord_id(discord_id)
      unless result.nil?
        result.party_id
      end
    end

    def find_by_discord_id(discord_id)
      members.where(discord_id: discord_id)
        .first rescue nil
    end

    def delete_by_discord_id(discord_id)
      members.where(discord_id: discord_id).delete
    end
  end
end
