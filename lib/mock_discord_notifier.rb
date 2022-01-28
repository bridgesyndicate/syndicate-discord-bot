class MockNotifier

  attr_accessor :receipts
  def initialize
    @receipts = Array.new
  end

  def notify(discord_ids)
    discord_ids.each do |discord_id|
      send_message(discord_id)
    end
  end

  def send_message(discord_id)
    @receipts.push(discord_id)
  end

end