require 'time'

class Scrims
  class Invite

    class TooManyMembersError < StandardError
      def initialize(n)
        msg="Too many members in party: #{n}"
        super
      end
    end

    attr_accessor :party_repo, :member_repo, :max_members
    DEFAULT_MAX_PARTY_MEMBERS = 4

    def initialize(rom)
      @party_repo = Scrims::PartyRepo.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
      @max_members = DEFAULT_MAX_PARTY_MEMBERS
    end

    def add_users_to_new_party(discord_id_1, discord_id_2)
      party_repo.transaction do |t|
        party = party_repo.create({ created_at: Time.now.utc.iso8601 })
        member_repo.create({ party_id: party.id,
                             discord_id: discord_id_1,
                             created_at: Time.now.utc.iso8601
                           })
        member_repo.create({ party_id: party.id,
                             discord_id: discord_id_2,
                             created_at: Time.now.utc.iso8601
                           })
      return party.id
      end
    end

    def add_user_to_existing_party(discord_id, existing_party)
      party_repo.transaction do |t|
        if party_repo.member_count(existing_party) >= max_members
          raise TooManyMembersError.new(max_members)
        end
        party_id = party_repo.by_pk(existing_party).first.id
        member_repo.create({
                             party_id: party_id,
                             discord_id: discord_id,
                             created_at: Time.now.utc.iso8601
                           })
        return party_id
      end
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
