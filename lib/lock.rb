require 'rom'
require 'securerandom'

class LockStorage

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
        create_table(conf) unless use_postgres?
        conf.relation(:locks) do
          schema(infer: true)
        end
      end
    end

    def create_pg_table
      ROM.container(:sql, container_type) do |conf|
        create_table(conf)
      end
    end

    def create_table(conf)
      conf.default.create_table(:locks) do
        primary_key :id
        column :discord_id, String, null: false, unique: true
        column :expires_at, DateTime, null: false
        column :created_at, DateTime, null: false
      end
    end

end

