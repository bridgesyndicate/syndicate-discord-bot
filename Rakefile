require 'pry'
require 'bundler'

Bundler.require
libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'ranked/storage'
require 'helpers'

task default: %w/create_tables/

task :create_tables do
  %w/discord_user_queue/.each do |table|
    Rake::Task["create_#{table}_table"].execute
  end
end

task :create_discord_user_queue_table do
  Ranked::SqlTables.create_table
end
