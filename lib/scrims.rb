require 'rom'
require 'securerandom'

require 'scrims/party_repo'
require 'scrims/member_repo'
require 'scrims/party/invite'
require 'scrims/party/list'
require 'scrims/party/leave'
require 'scrims/duel'
require 'scrims/lock'
require 'scrims/lock_repo'

class Scrims
  class Storage

    def uri
      "postgres://AmazonPgUsername:AmazonPgPassword@#{ENV['POSTGRES_HOST']}/postgres"
    end

    def use_postgres?
      !ENV['POSTGRES_HOST'].nil?
    end

    def container_type
      use_postgres? ? uri : 'sqlite::memory'
    end

    def rom
      ROM.container(:sql, container_type) do |conf|
        create_tables(conf) unless use_postgres?
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

        conf.relation(:locks) do
          schema(infer: true) do
            associations do
              has_many :members
            end
          end
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
        column :created_at, DateTime, null: false
      end
      conf.default.create_table(:locks) do
        primary_key :id
        column :discord_id, String, null: false, unique: true
        column :created_at, DateTime, null: false
      end
    end
  end
end
