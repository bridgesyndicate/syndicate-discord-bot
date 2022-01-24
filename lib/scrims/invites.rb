class Scrims
  class Invites
    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def accept(discord_id_1, discord_id_2)
      party_repo.transaction do |t|
        party = party_repo.create({
                                    party_uuid: SecureRandom.uuid,
                                    created_at: Time.now.to_i
                                  })
        member_repo.create({ party_id: party.id, discord_id: discord_id_1 })
        member_repo.create({ party_id: party.id, discord_id: discord_id_2 })
        return party
      end
    end
  end
end
