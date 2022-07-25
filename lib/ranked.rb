require 'rom'

require 'ranked/player'
require 'ranked/match'
require 'ranked/queue'

class Ranked
  MAX_QUEUE_TIME = 15
  MAX_ELO_DELTA = 100
  class Storage

    def rom
      ROM.container(:sql, container_type) do |conf|
        create_tables(conf) unless use_postgres?
        conf.relation(:discord_user_queue) do
          schema(infer: true)
        end
      end
    end

    def create_pg_tables
      ROM.container(:sql, container_type) do |conf|
        create_tables(conf)
      end
    end

    def create_tables(conf)
      conf.default.connection.create_table(:discord_user_queue) do
        primary_key :discord_id
        column :discord_username, String, null: false
        column :queue_time, Integer, null: false
        column :elo, Integer, null: false, default: STARTING_ELO
      end
    end
  end
end
