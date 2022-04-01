require 'integer'

class Scrims
  class Duel
    class PartySizesUnequalError < StandardError
      def initialize(n)
        msg="Unequal party sizes: #{n}"
        super
      end
    end
    class ExpiredDuelError < StandardError
    end
    class LockedPlayerError < StandardError
    end
    class MissingDuelError < StandardError
    end
    class InvalidAcceptorError < StandardError
    end

    class MockRom
      attr_accessor :discord_id
      def initialize(discord_id)
        @discord_id = discord_id.to_s
      end
    end

    class DuelRequest < ROM::Repository[:duels]
      commands :create
    end

    attr_accessor :party_repo, :member_repo, :discord_resolver, :goals, :length,
                  :red_party, :blue_party, :red_names, :blue_names, :elo_resolver,
                  :notifier, :from_discord_id, :duel_request, :locks, :uuid,
                  :elo_hash

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
      @duel_request = DuelRequest.new(rom)
      @goals = 5
      @length = 900
      @locks = Locks.new(rom)
      @elo_hash = {}
    end

    def get_participants(participant_json)
      obj = JSON.parse(participant_json)
      obj['red'] + obj['blue']
    end

    def is_locked?(duel)
      locks
        .locked?(get_participants(duel.first.participants))
    end

    def lock_all_players(duel)
      get_participants(duel.first.participants).each do |player|
        locks.lock(player, 30.minutes)
      end
    end

    def is_blue_team?(duel, discord_id)
      JSON.parse(duel.first.participants)['blue']
        .include?(discord_id)
    end

    def reconstitue_party_lists(duel)
      participants = JSON.parse(duel.first.participants)
      @red_party = participants['red'].map{ |p| MockRom.new(p) }
      @blue_party = participants['blue'].map{ |p| MockRom.new(p) }
    end

    def accept(uuid, discord_id)
      duel_request.transaction do |t|
        duel = duel_request.duels.where(uuid: uuid)
        if duel.count == 1
          expiry = (Time.now - 1.minutes).utc.iso8601
          if duel.where{ created_at <= expiry }.count == 1
            raise ExpiredDuelError
          end
        else
          raise MissingDuelError
        end
        raise Scrims::Duel::LockedPlayerError if is_locked?(duel)
        raise Scrims::Duel::InvalidAcceptorError unless is_blue_team?(duel, discord_id)
        reconstitue_party_lists(duel)
        lock_all_players(duel)
      end
      @uuid = uuid
    end

    def blue_party_discord_id_list
      blue_party.map{ |p| p.discord_id }
    end

    def red_party_discord_id_list
      red_party.map{ |p| p.discord_id }
    end

    def to_discord_id_list
      blue_party_discord_id_list # blue receives the duel
    end

    def make_duel_request
      @uuid = SecureRandom.uuid
      participants = {
        red: red_party_discord_id_list,
        blue: blue_party_discord_id_list
      }.to_json
      duel_request.create({
                             uuid: uuid,
                             created_at: Time.now.utc.iso8601,
                             participants: participants
                          })
      return uuid
    end

    def create_duel(red_discord_id, blue_discord_id)
      raise 'Inputs must be strings' if red_discord_id.class != String or blue_discord_id.class != String
      @from_discord_id = red_discord_id # red initiates the duel
      red = member_repo.find_by_discord_id(red_discord_id)
      blue = member_repo.find_by_discord_id(blue_discord_id)

      if red and blue # both are in parties
        syn_logger "both are in parties red: #{red}, blue: #{blue}"
        @red_party = party_repo.with_members(red.party_id).first.members
        @blue_party = party_repo.with_members(blue.party_id).first.members
        syn_logger "both are in parties red_party: #{red_party}, blue_party: #{blue_party}"
        if (red_party.size != blue_party.size)
          raise PartySizesUnequalError.new("#{red_party.size}, #{blue_party.size}")
        end
      elsif red or blue # one in a party
        raise PartySizesUnequalError.new('Both members must be in a party')
      else # neither in a party
        syn_logger "neither in party red: #{red}, blue: #{blue}"
        @red_party = Array.new.push(MockRom.new(red_discord_id))
        @blue_party = Array.new.push(MockRom.new(blue_discord_id))
        syn_logger "neither in party red_party: #{red_party}, blue_party: #{blue_party}"
      end
      make_duel_request
    end

    def resolve_party_names
      @red_names = red_party.map do |member|
          discord_resolver.resolve_name_from_discord_id(member.discord_id)
      end
      @blue_names = blue_party.map do |member|
          discord_resolver.resolve_name_from_discord_id(member.discord_id)
      end
    end

    def resolve_elo
      elo_resolver
        .discord_ids = red_party_discord_id_list + blue_party_discord_id_list
    end


    def duel_hash
      {
        uuid: uuid,
        red_team_discord_ids: red_party.map{ |member| member.discord_id },
        red_team_discord_names: red_names,
        blue_team_discord_ids: blue_party.map{ |member| member.discord_id },
        blue_team_discord_names: blue_names,
        required_players: red_party.size * 2,
        goals_to_win: goals,
        game_length_in_seconds: length,
        queued_at: Time.now.utc.iso8601,
        accepted_by_discord_ids: (red_party + blue_party).map{ |member|
          {
            discord_id: member.discord_id,
            accepted_at: Time.now.utc.iso8601
          }
        },
        queued_via: self.class,
        elo_before_game: elo_resolver.resolve_elo_from_discord_ids
      }
    end

    def to_json
      resolve_party_names
      resolve_elo
      JSON.pretty_generate(duel_hash)
    end
  end
end
