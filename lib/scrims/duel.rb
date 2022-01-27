class Scrims
  class Duel

    class PartySizesUnequal < StandardError
      def initialize(n)
        msg="Unequal party sizes: #{n}"
        super
      end
    end

    attr_accessor :party_repo, :member_repo

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
    end

    def duel(discord_id_1, discord_id_2)
      party_id_1 = @member_repo.find_by_discord_id(discord_id_1)
                  .party_id
      party_id_2 = @member_repo.find_by_discord_id(discord_id_2)
                  .party_id
      if (party_size_1 = @party_repo.member_count(party_id_1)) !=
         (party_size_2 = @party_repo.member_count(party_id_2))
        raise PartySizesUnequal.new("#{party_size_1}, #{party_size_2}")
      end

      GameMaker.make_team_duel()
      
    end
  end
end
