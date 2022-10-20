require 'rom'
require 'securerandom'
require 'rom-helpers'

require 'scrims/party/invite'
require 'scrims/party/list'
require 'scrims/party/leave'
require 'scrims/duel'
require 'scrims/locks'

require 'scrims/storage/queue'
require 'scrims/storage/party'
require 'scrims/storage/member'
require 'scrims/storage/leaderboard'
require 'scrims/match'
require 'scrims/queue'
require 'scrims/leaderboard'



class Scrims
  MAX_QUEUE_TIME = 15
  MAX_ELO_DELTA = 100

  class Storage
    def rom
      ROM.container(:sql, container_type) do |conf|
        create_tables(conf) unless use_postgres?
        conf.relation(:discord_user_queue) do
          schema(infer: true) do
            associations do
              belongs_to :parties
            end
          end
        end
        conf.relation(:parties) do
          schema(infer: true) do
            associations do
              has_many :members
            end
          end
        end
        conf.relation(:members) do
          schema(infer: true) do
            associations do
              belongs_to :parties
            end
          end
        end
        conf.relation(:duels) do
          schema(infer: true) do
            associations do
              belongs_to :parties
            end
          end
        end
        conf.relation(:locks) do
          schema(infer: true)
        end
        conf.relation(:syndicate_leader_board) do
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
      conf.default.create_table(:parties) do
        primary_key :id
        column :created_at, DateTime, null: false
      end
      conf.default.create_table(:members) do
        primary_key :id
        foreign_key :party_id, :parties
        column :discord_id, String, null: false, unique: true
        column :discord_username, String, null: false
        column :created_at, DateTime, null: false
      end
      conf.default.connection.create_table(:discord_user_queue) do
        primary_key :id
        foreign_key :party_id, :parties
        column :discord_id, String
        column :discord_username, String
        column :queue_time, Integer, null: false
        column :elo, Integer, null: false
        column :party_size, Integer, null: false, default: 1
      end
      conf.default.create_table(:duels) do
        primary_key :id
        column :uuid, String, null: false, unique: true
        column :participants, String, null: false
        column :created_at, DateTime, null: false
      end
      conf.default.create_table(:locks) do
        primary_key :id
        column :discord_id, String, null: false, unique: true
        column :expires_at, DateTime, null: false
        column :created_at, DateTime, null: false
      end
      conf.default.create_table(:syndicate_leader_board) do
        column :discord_id, String, null: false
        column :minecraft_uuid, String, size: 36, null: false
        column :elo, Integer, null: false
        column :wins, Integer, null: false, default: 0
        column :losses, Integer, null: false, default: 0
        column :ties, Integer, null: false, default: 0
        column :season, String
        index [:discord_id, :minecraft_uuid, :season], unique: true
        index :losses
        index :ties
        index :wins
      end
    end
  end
end
