class Scrims
  class ListParty

    class EmptyPartyError < StandardError
      def initialize()
        msg="Cannot show list of empty party"
        super
      end
    end

    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def list(discord_id)
      member = member_repo.find_by_discord_id(discord_id)
      if member.nil?
        raise EmptyPartyError.new
      else
        party_repo.with_members(member.party_id).first
          .members
          .map { |member| member.discord_id }
      end
    end
  end
end
