require 'rom'
require 'rom-sql'

class Ranked
  class SqlTables
    def self.rom
      ROM.container(:sql, ENV['POSTGRES_URL']) do |config|
        config.relation(:discord_user_queue) do
          schema(infer: true)
        end
      end
    end
  end
end
