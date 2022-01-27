class Scrims
  class ListParty
    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def list(discord_id)
      member = member_repo.find_by_discord_id(discord_id)
      unless member.nil?
        party_repo.with_members(member.party_id).first
          .members
          .map { |member| member.discord_id }
      else
        []
      end
    end
  end
end