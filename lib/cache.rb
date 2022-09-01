require 'lru_redux'
require 'singleton'

class Cache
  include Singleton
  attr_accessor :lru_cache

  def cache
    @lru_cache ||= LruRedux::Cache.new(500)
  end
end
