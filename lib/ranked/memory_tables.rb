require 'rom'
require 'rom-sql'

class Ranked
  class MemoryTables
    def self.rom
      ROM.container(:sql, 'sqlite::memory') do |config|
        config.default.connection.create_table(:discord_user_queue) do
          primary_key :discord_id
          column :discord_username, String, null: false
          column :queue_time, Integer, null: false
          column :elo, Integer, null: false, default: STARTING_ELO
        end
        config.relation(:discord_user_queue) do
          schema(infer: true)
        end
      end
    end
  end
end
