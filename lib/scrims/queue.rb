class Scrims
  class Queue
    class AlreadyQueuedError < StandardError
    end
    attr_accessor :queue, :party_repo
    def initialize(rom)
      @queue = Scrims::Storage::Queue.new(rom)
      @party_repo = Scrims::Storage::Party.new(rom)
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
    def queue_player queued_player
      if queue.by_discord_id(queued_player[:discord_id]).to_a.empty?
        queue.create(queued_player)
      else
        raise Scrims::Queue::AlreadyQueuedError
      end
    end
    def queue_party queued_party
      party_size = party_repo
        .with_members(queued_party[:party_id])
        .first
        .members
        .size
      queue.create(queued_party
                     .merge(party_size: party_size)
                   )
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
  end
end
