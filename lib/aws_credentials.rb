require 'singleton'

class AwsCredentials
  include Singleton

  ALMOST_SIX_HOURS_IN_SECONDS = 60 * 60 * 6 - 60

  attr_accessor :region, :refresh_time, :cached_credentials

  def production_credentials
    provider = Aws::ECSCredentials.new
    @credentials = provider.credentials
  end

  def dev_credentials
    id = ENV['AWS_ACCESS_KEY_ID'] || 'access'
    secret = ENV['AWS_SECRET_ACCESS_KEY'] || 'secret'
    @credentials = Aws::Credentials.new(id, secret)
  end

  def get_credentials
    syn_logger 'refreshing aws_credentials'
    ENV['SYNDICATE_ENV'] == 'production' ? production_credentials : dev_credentials
  end

  def credentials
    if refresh_time.nil? or refresh_time < Time.now.to_i
      @refresh_time = Time.now.to_i + ALMOST_SIX_HOURS_IN_SECONDS
      @cached_credentials = get_credentials
    else
      cached_credentials
    end
  end

  def initialize
    @region = ENV['AWS_REGION']
  end
end
