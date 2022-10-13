require 'yaml'
require 'ostruct'

class BotConfig
  def self.config
    @@config
  end

  def self.load(config_string)
    @@config = OpenStruct
      .new(YAML.load(config_string))
  end
 end
