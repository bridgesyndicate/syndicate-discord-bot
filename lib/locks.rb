require 'rom'
require 'securerandom'
require 'rom-helpers'

class DoubleLockError < StandardError
end

class Locks < ROM::Repository[:locks]
  commands :create

  def now
     Time.now.utc
  end

  def locked?(discord_id)
    now1 = now
    locks
      .where(discord_id: discord_id)
      .where{ (expires_at > now1 ) } # no idea why now does not work
      .count == 1
  end

  def lock(discord_id, duration_seconds)
    expires_at = now + duration_seconds
    begin
      self.create({ discord_id: discord_id,
                    expires_at: expires_at,
                    created_at: now
                  }).id
    rescue
      raise DoubleLockError
    end
  end
end

class LockStorage
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

