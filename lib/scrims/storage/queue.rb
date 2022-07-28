require 'rom-repository'

class Scrims
  class Storage
    class Queue < ROM::Repository[:discord_user_queue]
      commands :create, update: :by_pk

      def sort_by_queue_time(party_size=1)
        discord_user_queue
          .where(party_size: party_size)
          .order do
          queue_time.asc
        end.to_a
      end

      def sort_by_elo(party_size=1)
        discord_user_queue
          .where(party_size: party_size)
          .order do
          elo.asc
        end.to_a
      end

      def by_party_size(party_size)
        discord_user_queue.where(party_size: party_size)
      end

      def by_discord_id(id)
        discord_user_queue.where(discord_id: id)
      end

      def ids
        discord_user_queue.pluck(:discord_id)
      end

      def all
        discord_user_queue.to_a
      end

      def size
        discord_user_queue.to_a.size
      end

      def delete_by_pk(pk)
        discord_user_queue.by_pk(pk).delete
      end
    end
  end
end
