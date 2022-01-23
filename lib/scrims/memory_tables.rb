require 'rom'
require 'rom-sql'

class Scrims
  class MemoryTables
    def self.rom
      ROM.container(:sql, 'sqlite::memory') do |config|
        config.default.connection.create_table(:parties) do
          primary_key :party_id
          column :party_uuid, String, null: false
          column :created_at, Integer, null: false
        end
        config.relation(:parties) do
          schema(infer: true)
        end
      end
    end
  end
end
