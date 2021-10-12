require 'rom-repository'

class Leaderboard < ROM::Repository[:syndicate_leader_board]
  def self.postgres_host
    ENV['POSTGRES_HOST'] || 'localhost'
  end

  def self.uri
    "postgres://AmazonPgUsername:AmazonPgPassword@#{postgres_host}/postgres"
  end

  def self.rom
    ROM.container(:sql, uri) do |config|
      config.relation(:syndicate_leader_board) do
        schema(infer: true)
      end
    end
  end

  def sort_by_elo
    syndicate_leader_board.order do
      elo.desc
    end.to_a
  end
end
