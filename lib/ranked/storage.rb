require 'ranked/memory_tables'
require 'ranked/sql_tables'

class Ranked
  class Storage
    def self.rom
      if ENV['POSTGRES_HOST'].nil?
        MemoryTables.rom
      else
        SqlTables.rom
      end
    end
  end
end
