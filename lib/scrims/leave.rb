class Scrims
  class Leave

    class MemberNotInParty < StandardError
      def initialize()
        msg="Cannot leave nonexistent party"
        super
      end
    end

    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def leave(discord_id)
      if member_repo.get_party(discord_id).nil?
        raise MemberNotInParty.new
      else
        party_uuid = remove_user_from_party(discord_id)
        if party_repo.member_count(party_uuid) == 1
          remove_single_member_party(party_uuid)
        end
      end
    end

    def remove_single_member_party(party_uuid)
      discord_id = party_repo.members(party_uuid).members.first.discord_id
      remove_user_from_party(discord_id)
      party_repo.by_uuid(party_uuid).delete # TODO: put an index on party_uuid
    end

    def remove_user_from_party(discord_id)
      member = member_repo.find_by_discord_id(discord_id)
      party_uuid = member.first.parties.party_uuid
      member.delete
      return party_uuid
    end
  end
end
