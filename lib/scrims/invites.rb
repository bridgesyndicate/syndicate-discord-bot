class Scrims
  class Invites
    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def add_users_to_new_party(discord_id_1, discord_id_2)
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

    def add_user_to_existing_party(discord_id, existing_party)
      party = party_repo.by_uuid(existing_party);
      member_repo.create({ party_id: party.id, discord_id: discord_id })
      return party
    end

    def accept(invitor, invitee)
      party_for_invitor = member_repo.get_party(invitor)
      party_for_invitee = member_repo.get_party(invitee)

      if party_for_invitor and party_for_invitee
        member_repo.get_party(invitee)
        raise 'Cannot party when both members are in different parties'
      elsif party_for_invitor or party_for_invitee
        if party_for_invitor
          return add_user_to_existing_party(invitee, party_for_invitor)
        end
        if party_for_invitee
          return add_user_to_existing_party(invitor, party_for_invitee)
        end
      else
        add_users_to_new_party(invitor, invitee)
      end
    end
  end
end
