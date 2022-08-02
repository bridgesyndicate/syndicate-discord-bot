require 'pry'
require 'bundler'

Bundler.require
libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'scrims'
require 'helpers'

task default: %w/create_scrims_tables/

task :create_scrims_tables do
  if ENV['POSTGRES_HOST']
    storage = Scrims::Storage.new
    storage.create_pg_tables
  else
    puts 'ERROR: You should set POSTGRES_HOST'
  end
end