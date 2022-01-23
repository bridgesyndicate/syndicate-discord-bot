require 'rom'
require 'rom-sql'

class Scrims
  class SqlTables
    def self.uri
      "postgres://AmazonPgUsername:AmazonPgPassword@#{ENV['POSTGRES_HOST']}/postgres"
    end
    def self.rom
      ROM.container(:sql, uri) do |config|
        config.relation(:parties) do
          schema(infer: true)
        end
      end
    end
    def self.create_table
      raise 'you must set POSTGRES_HOST' if ENV['POSTGRES_HOST'].nil?
      ROM.container(:sql, uri) do |config|
        config.default.connection.create_table(:parties) do
          primary_key :party_id
          column :party_uuid, String, null: false
          column :created_at, Integer, null: false
        end
      end
    end
  end
end
