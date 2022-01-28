class Scrims
  class Duel

    class PartySizesUnequal < StandardError
      def initialize(n)
        msg="Unequal party sizes: #{n}"
        super
      end
    end

    attr_accessor :party_repo, :member_repo, :discord_resolver, :goals, :length,
    :red_party, :blue_party, :red_names, :blue_names, :elo_resolver, :notifier

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
      @goals = 5
      @length = 900
    end

    def create_duel(red_discord_id, blue_discord_id)
      red = member_repo.find_by_discord_id(red_discord_id)
      blue = member_repo.find_by_discord_id(blue_discord_id)

      if red and blue # both are in parties
        @red_party = party_repo.with_members(red.party_id).first.members
        @blue_party = party_repo.with_members(blue.party_id).first.members
        if (red_party.size != blue_party.size)
          raise PartySizesUnequal.new("#{red_party.size}, #{blue_party.size}")
        end
      elsif red or blue # one in a party
        raise PartySizesUnequal.new('Both members must be in a party')
      else # neither in a party
        @red_party = [OpenStruct.new(discord_id: red_discord_id.to_s)]
        @blue_party = [OpenStruct.new(discord_id: blue_discord_id.to_s)]
      end
    end

    def resolve_party_names
      @red_names = red_party.map do |member|
          discord_resolver.resolve_name_from_discord_id(member.discord_id)
      end
      @blue_names = blue_party.map do |member|
          discord_resolver.resolve_name_from_discord_id(member.discord_id)
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
