class Scrims
  class Queue
    class LockedPlayerError < StandardError
    end
    class AlreadyQueuedError < StandardError
    end
    attr_accessor :queue, :party_repo, :elo_resolver, :member_repo, :lock_repo
    def initialize(rom)
      @queue = Scrims::Storage::Queue.new(rom)
      @party_repo = Scrims::Storage::Party.new(rom)
      @member_repo = Scrims::MemberRepo.new(rom)
      @lock_repo = Scrims::Locks.new(rom)
    end
    def size(party_size=1)
      queue
        .by_party_size(party_size)
        .to_a
        .size
    end
    def dequeue_player queued_player
      queue.by_discord_id(queued_player).delete
    end
    def dequeue_party party_id
      queue.by_party_id(party_id).delete
    end
    def queue_player queued_player
      discord_id = queued_player[:discord_id]
      if lock_repo.locked?(discord_id)
        raise Scrims::Queue::LockedPlayerError
      elsif !queue.by_discord_id(discord_id).to_a.empty?
        raise Scrims::Queue::AlreadyQueuedError
      else
        elo_resolver.discord_ids = Array.new.push(discord_id)
        elo = elo_resolver
          .resolve_elo_from_discord_ids
          .fetch(discord_id)
        queue.create(queued_player
                       .merge(elo: elo['elo'], queue_time: now.to_i)
                     )
      end
    end

    def compute_average_elo(party_id)
      elo_resolver.discord_ids = party_repo
                                   .with_members(party_id)
                                   .first.members
                                   .map { |f| f.discord_id }
      elos = elo_resolver.resolve_elo_from_discord_ids
        .map{ |k,v| v['elo'] }
      (elos.sum / elos.size).to_i
    end

    def queue_party queued_party
      party_members = party_repo
          .with_members(queued_party[:party_id])
          .first
          .members
      discord_id_list = party_members.map { |member| member.discord_id }
      if lock_repo.locked?(discord_id_list)
        raise Scrims::Queue::LockedPlayerError
      elsif !queue.by_party_id(queued_party[:party_id]).to_a.empty?
        raise Scrims::Queue::AlreadyQueuedError
      else
        queue.by_party_id(queued_party[:party_id]).to_a.empty?
        elo = compute_average_elo(queued_party[:party_id])
        queue.create(queued_party
                       .merge(party_size: party_members.size)
                       .merge(elo: elo)
                       .merge(queue_time: now.to_i)
                    )
      end
    end
    def find_match_by_oldest_players(party_size=1)
      sorted_queue = queue.sort_by_queue_time(party_size=party_size)
      return [sorted_queue[0],
              sorted_queue[1] ]
    end
    def find_best_match_by_elo(party_size=1)
      sorted_queue = queue.sort_by_elo(party_size=party_size)
      best_delta = nil
      best_match = nil
      (sorted_queue.size-1).times do |idx|
        elo_delta = sorted_queue[idx+1].elo - sorted_queue[idx].elo
        if best_delta.nil? or elo_delta < best_delta
          best_match = idx
          best_delta = elo_delta
        end
      end
      return [sorted_queue[best_match],
              sorted_queue[best_match+1]]
    end
    def process_queue(party_size=1)
      if size(party_size=party_size) < 2
        return nil
      end
      if has_max_queue_time_players?(party_size=party_size)
        players = find_match_by_oldest_players(party_size=party_size)
        return new_match(players[0], players[1])
      end
      if size(party_size=party_size) == 2
        tmp = queue.by_party_size(party_size).to_a
        if within_elo(tmp[0], tmp[1])
          return new_match(tmp[0],
                           tmp[1])
        else
          return nil
        end
      end
      players = find_best_match_by_elo(party_size=party_size)
      return new_match(players[0],
                       players[1])
    end
    def within_elo(playerA, playerB)
      Match.within_elo(playerA, playerB)
    end
    def new_match(playerA, playerB)
      match = Match.new(playerA, playerB)
      queue.delete_by_pk(playerA.id)
      queue.delete_by_pk(playerB.id)
      return match
    end
    def has_max_queue_time_players?(party_size=1)
      sorted_queue = queue.sort_by_queue_time(party_size)
      sorted_queue[0].queue_time + MAX_QUEUE_TIME <= Time.now.to_i
    end
    def entity_queued?(entity)
      if entity.class == String
        !queue.by_discord_id(entity).to_a.empty?
      elsif entity.class == Integer
        !queue.by_party_id(entity).to_a.empty?
      else
        false
      end
    end
  end
end
