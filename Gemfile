# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "ed25519", "~> 1.2"
gem "faraday", "~> 1.4"
gem "functions_framework", "~> 0.9"
gem 'aws-sdk-secretsmanager'
gem 'aws-sdk-sqs'
gem 'aws-sigv4'
gem 'discordrb', github: 'shardlab/discordrb', branch: 'main'
gem 'lru_redux'
gem 'pg'
gem 'pry-byebug'
gem 'rom'
gem 'rom-sql'
gem 'sqlite3'
gem 'toys'
gem 'tzinfo'
gem 'tzinfo-data'

group :test do
  gem 'faker'
  gem 'json-schema'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'simplecov', require: false, group: :test
  gem 'timecop'
  gem 'webmock'
end
