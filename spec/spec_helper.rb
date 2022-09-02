require 'simplecov'
require 'webmock/rspec'
require 'helpers'

SimpleCov.start

SYNDICATE_ENV = ENV['SYNDICATE_ENV'] = 'test'
ENV['AWS_REGION'] = 'us-west-2'

Bundler.require(:default, 'test')

root = File.expand_path("..", File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

def seeded_random_kick_code(seed)
  srand((Digest::MD5.hexdigest seed).to_i(16))
  16.times.map{(('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a)
                 .sample}.join
end

# WebMock.allow_net_connect!
# And this goes in you 'it' example
#      WebMock.after_request do |request_signature, response|
#        puts "Request #{request_signature} was made and #{response.body}"
#      end
