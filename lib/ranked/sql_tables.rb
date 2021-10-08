require 'rom'
require 'rom-sql'

class Ranked
  class SqlTables
    def self.uri
      "postgres://AmazonPgUsername:AmazonPgPassword@#{ENV['POSTGRES_HOST']}/postgres"
    end
    def self.rom
      ROM.container(:sql, uri) do |config|
        config.relation(:discord_user_queue) do
          schema(infer: true)
        end
      end
    end
    def self.create_table
      raise 'you must set POSTGRES_HOST' if ENV['POSTGRES_HOST'].nil?
      ROM.container(:sql, uri) do |config|
        config.default.connection.create_table(:discord_user_queue) do
          primary_key :discord_id
          column :discord_username, String, null: false
          column :queue_time, Integer, null: false
          column :elo, Integer, null: false, default: STARTING_ELO
        end
      end
    end
  end
end
