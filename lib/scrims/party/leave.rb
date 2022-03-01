class Scrims
  class Leave

    class MemberNotInPartyError < StandardError
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
        raise MemberNotInPartyError.new
      else
        party_id = remove_user_from_party(discord_id)
        if party_repo.member_count(party_id) == 1
          remove_single_member_party(party_id)
        end
      end
    end

    def remove_single_member_party(party_id)
      party_repo.destroy(party_id)
    end

    def remove_user_from_party(discord_id)
      party_id = member_repo.find_by_discord_id(discord_id).party_id
      member_repo.delete_by_discord_id(discord_id)
      return party_id
    end
  end
end
