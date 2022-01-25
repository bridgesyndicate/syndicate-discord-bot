require 'rom'
require 'securerandom'

require 'scrims/party_repo'
require 'scrims/member_repo'
require 'scrims/invites'
require 'scrims/list_party'

class Scrims
  class Storage

    attr_accessor :rom

    def initialize
      @rom = ROM.container(:sql, 'sqlite::memory') do |conf|
        conf.default.create_table(:parties) do
          primary_key :id
          column :party_uuid, String, null: false
        end

        conf.default.create_table(:members) do
          primary_key :id
          foreign_key :party_id, :parties
          column :discord_id, Integer, null: false, unique: true
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
      end
    end
  end
end