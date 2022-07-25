class Ranked
  class Queue
    attr_accessor :queue, :process_counter
    def initialize
      rom = Ranked::Storage.new.rom
      @queue = Ranked::Storage::Queue.new(rom)
      @process_counter = 0
    end
    def size
      @queue.all.size
    end
    def dequeue_player queued_player
      queue.by_id(queued_player).delete
    end
    def queue_player queued_player
      queue.create(queued_player)
    end
    def find_match_by_oldest_players
      sorted_queue = queue.sort_by_queue_time
      return [sorted_queue[0],
              sorted_queue[1] ]
    end
    def find_best_match_by_elo
      sorted_queue = queue.sort_by_elo
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
    def process_queue
      @process_counter += 1
      if queue.size < 2
        return nil
      end
      if has_max_queue_time_players?
        players = find_match_by_oldest_players
        return new_match(players[0], players[1])
      end
      if queue.size == 2
        if within_elo(queue.all[0], queue.all[1])
          return new_match(queue.all[0],
                           queue.all[1])
        else
          return nil
        end
      end
      players = find_best_match_by_elo
      return new_match(players[0],
                       players[1])
    end
    def within_elo(playerA, playerB)
      Match.within_elo(playerA, playerB)
    end
    def new_match(playerA, playerB)
      match = Match.new(playerA, playerB)
      queue.delete(playerA.discord_id)
      queue.delete(playerB.discord_id)
      return match
    end
    def has_max_queue_time_players?
      sorted_queue = queue.sort_by_queue_time
      sorted_queue[0].queue_time + MAX_QUEUE_TIME <= Time.now.to_i
    end
  end
end
