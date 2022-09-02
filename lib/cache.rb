require 'lru_redux'
require 'singleton'

class Cache
  include Singleton
  attr_accessor :lru_cache
  MAX_CACHE_SIZE = 500

  def cache
    @lru_cache ||= LruRedux::Cache.new(MAX_CACHE_SIZE)
  end
end
