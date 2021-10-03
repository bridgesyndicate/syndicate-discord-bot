class DelayedWorker
  attr_accessor :delay, :block
  def initialize delay, &block
    @delay = delay
    @block = block
  end
  def run
    Thread.new {
      sleep(delay)
      block.call
    }
  end
end
