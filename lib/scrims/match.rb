class Scrims
  class Match
    attr_accessor :playerA, :playerB

    def self.within_elo(playerA, playerB)
      (playerA.elo-playerB.elo).abs <= MAX_ELO_DELTA
    end
    def initialize(playerA, playerB)
      @playerA = playerA
      @playerB = playerB
    end
  end
end
