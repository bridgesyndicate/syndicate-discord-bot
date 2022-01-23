require 'scrims/memory_tables'
require 'scrims/sql_tables'

class Scrims
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
