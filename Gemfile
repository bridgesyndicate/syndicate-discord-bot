# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "ed25519", "~> 1.2"
gem "faraday", "~> 1.4"
gem "functions_framework", "~> 0.9"
gem 'aws-sdk-secretsmanager'
gem 'aws-sdk-sqs'
gem 'aws-sigv4'
#gem 'discordrb', github: 'kenberland/discordrb', branch: 'main'
gem 'discordrb', github: 'swarley/discordrb-1', branch: 'refactor/webhook-view'
gem 'pg'
gem 'pry-byebug'
gem 'rom'
gem 'rom-sql'
gem 'sqlite3'
gem 'toys'

group :test do
  gem 'faker'
  gem 'simplecov', require: false, group: :test
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'timecop'
  gem 'webmock'
end
