class Scrims
  class Party < ROM::Repository[:parties]
    commands :create, update: :by_pk, delete: :by_pk

    def by_party_uuid(party_uuid)
      parties.where({ party_uuid: party_uuid }).to_a
    end

    def all
      parties.to_a
    end

  end
end
