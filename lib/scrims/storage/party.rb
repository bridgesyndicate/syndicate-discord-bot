class Scrims
  class PartyRepo < ROM::Repository[:parties]
    commands :create, update: :by_pk, delete: :by_pk

    def by_pk(party_id)
      parties.by_pk(party_id)
    end

    def exists?(party_id)
      by_pk(party_id)
        .count == 1
    end

    def with_members(party_id)
      parties.by_pk(party_id)
        .combine(:members)
    end

    def member_count(party_id)
      parties.by_pk(party_id)
        .combine(:members)
        .one
        .members
        .count rescue 0
    end

    def has_members?(party_id)
      member_count(party_id) > 0
    end

    def empty?(party_id)
      member_count(party_id) == 0
    end

    def destroy(pk)
      parties.members.where(party_id: pk).delete
      delete(pk)
    end
  end
end
