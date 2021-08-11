require 'singleton'

class AwsCredentials
  include Singleton

  attr_accessor :credentials, :region

  def initialize
    @region = ENV['AWS_REGION']

    if ENV['SYNDICATE_ENV'] == 'production'
      provider = Aws::ECSCredentials.new
      @credentials = provider.credentials
    else
      id = ENV['AWS_ACCESS_KEY_ID'] || 'access'
      secret = ENV['AWS_SECRET_ACCESS_KEY'] || 'secret'
      @credentials = Aws::Credentials.new(id, secret)
    end
  end
end
