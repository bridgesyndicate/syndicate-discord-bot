class MockSyndicateWebService
  def self.send_game_to_syndicate_web_service(game_json)
    @@game_json = game_json
    Net::HTTPOK.new(1.1, 200, '')
  end
end
