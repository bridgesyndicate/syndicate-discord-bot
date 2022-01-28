class Scrims
  class Duel

    class PartySizesUnequal < StandardError
      def initialize(n)
        msg="Unequal party sizes: #{n}"
        super
      end
    end

    attr_accessor :party_repo, :member_repo, :discord_resolver, :goals, :length,
    :red_party, :blue_party, :red_names, :blue_names, :elo_resolver

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
      @goals = 5
      @length = 900
    end

    def create_duel(red_discord_id, blue_discord_id)
      binding.pry;1
      red_party_id = member_repo.find_by_discord_id(red_discord_id)
                  .party_id
      blue_party_id = member_repo.find_by_discord_id(blue_discord_id)
                  .party_id

      @red_party = party_repo.with_members(red_party_id).first.members
      @blue_party = party_repo.with_members(blue_party_id).first.members
      if (red_party.size != blue_party.size)
        raise PartySizesUnequal.new("#{red_party.size}, #{blue_party.size}")
      end
    end

    def resolve_party_names
      @red_names = red_party.map do |id| 
          discord_resolver.resolve_name_from_discord_id(id)
      end
      @blue_names = blue_party.map do |id| 
          discord_resolver.resolve_name_from_discord_id(id)
      end
    end

    def duel_hash
      {
        uuid: SecureRandom.uuid,
        red_team_discord_ids: red_party.map{ |member| member.discord_id },
        red_team_discord_names: red_names,
        blue_team_discord_ids: blue_party.map{ |member| member.discord_id },
        blue_team_discord_names: blue_names,
        required_players: red_party.size * 2,
        goals_to_win: goals,
        game_length_in_seconds: length,
        queued_at: Time.now.utc.iso8601,
        accepted_by_discord_ids: red_party.map{ |member|
          {
            discord_id: member.discord_id,
            accepted_at: Time.now.utc.iso8601
          }
        },
        queued_via: self.class,
        elo_before_game: elo_resolver
          .resolve_elo_from_discord_ids(red_party.map{ |member| member.discord_id } +
                                        blue_party.map{ |member| member.discord_id })
      }
    end
    
    def to_json
      resolve_party_names
      JSON.pretty_generate(duel_hash)
    end
  end
end
