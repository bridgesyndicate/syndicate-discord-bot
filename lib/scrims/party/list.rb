class Scrims
  class ListParty
    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def list(discord_id)
      result = member_repo.find_by_discord_id(discord_id)
      unless result.first.nil?
        party_uuid = result.first.parties.party_uuid
        party_repo.members(party_uuid).map { |member| member.discord_id }
      else
        []
      end
    end
  end
end
