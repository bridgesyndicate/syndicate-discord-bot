require 'singleton'

class MockSecrets
  include Singleton

  def get_secret(secret_key)
    token = ENV["DEV_BOT_TOKEN"]
    { "DISCORD_BOT_TOKEN" => token }
  end

end