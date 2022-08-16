require 'rom-repository'

class Scrims
  class Storage
    class Leaderboard < ROM::Repository[:syndicate_leader_board]
      commands :create

      def sort_by_elo
        syndicate_leader_board.order do
          elo.desc
        end.to_a
      end

      def sort_by_wins
        syndicate_leader_board.order do
          wins.desc
        end.to_a
      end

      def sort_by_losses
        syndicate_leader_board.order do
          losses.desc
        end.to_a
      end

      def sort_by_ties
        syndicate_leader_board.order do
          ties.desc
        end.to_a
      end

    end
  end
end