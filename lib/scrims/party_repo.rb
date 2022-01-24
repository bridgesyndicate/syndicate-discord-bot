class Scrims
  class PartyRepo < ROM::Repository[:parties]
    commands :create, update: :by_pk, delete: :by_pk

    def members(party_uuid)
      parties.where(party_uuid: party_uuid)
        .combine(:members).to_a
        .first.members
    end

    def member_count(party_uuid)
      parties.where(party_uuid: party_uuid)
        .combine(:members).to_a
        .first.members.size
    end

    def has_members?(party_uuid)
      parties.where(party_uuid: party_uuid)
        .combine(:members).to_a
        .first.members.any?
    end

    def find_id_by_party_uuid(party_uuid)
      parties.where(party_uuid: party_uuid)
        .to_a
        .first[:id]
    end

    def by_uuid(party_uuid)
      parties.where(party_uuid: party_uuid)
        .first
    end

    def party_uuid_exists?(party_uuid)
      !parties.where(party_uuid: party_uuid)
        .to_a.empty?
    end
  end
end
