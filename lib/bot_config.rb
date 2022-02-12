require 'yaml'
require 'ostruct'

class BotConfig
  def self.config
    @@config
  end

  def self.load(config_string, namespace)
    @@config = OpenStruct
      .new(YAML.load(config_string)[namespace.to_s])
  end
 end
