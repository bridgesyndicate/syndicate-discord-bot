require 'json'

class GameStream
  attr_accessor :body, :message

  def initialize(message)
    @message = message
    @body = JSON.parse(message.body, object_class: OpenStruct)
  end

  def event_name
    body.event_name
  end

  def game_score
    !!body.dynamodb.new_image.game.game_score
  end

  def modified?
    event_name == 'MODIFY'
  end

  def new_game?
    modified? and !game_score
  end

  def game_score?
    modified? and game_score
  end

  def process?
    new_game? || game_score?
  end

  def new_image
    body.dynamodb.new_image
  end

  def receipt_image
    message.receipt_image
  end

end