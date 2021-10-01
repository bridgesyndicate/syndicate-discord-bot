require 'simplecov'
require 'webmock/rspec'
require 'helpers'

SimpleCov.start

ENV['SYNDICATE_ENV'] = 'test'
ENV['AWS_REGION'] = 'us-west-2'

Bundler.require(:default, 'test')

root = File.expand_path("..", File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

# WebMock.allow_net_connect!
