require 'discord_webhook_client'
require 'game_stream'

class SqsPoller
  attr_accessor :sqs_client, :thread, :discord_webhook_client

  SQS_QUEUE_URL = 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_player_messages'

  def initialize
    @sqs_client = Aws::SQS::Client
                    .new(credentials: AwsCredentials.instance.credentials)
    @discord_webhook_client = DiscordWebhookClient.instance
  end

  def unlock_players(game)
    lock_repo = Scrims::Locks.new($rom)
    ids = game.blue_team_discord_ids + game.red_team_discord_ids
    lock_repo.unlock(ids)
  end

  def poll_sqs
    $stdout.sync = true
    while true
      res = sqs_client.receive_message({
                                         queue_url: SQS_QUEUE_URL,
                                         wait_time_seconds: 20
                                       })
      res.messages.each do |message|
        game_stream = GameStream.new(message)
        if game_stream.process?
          if game_stream.game_score?
            discord_webhook_client.send_game_score(game_stream.new_image)
            unlock_players(game_stream.new_image.game)
          elsif game_stream.aborted?
            unlock_players(game_stream.new_image.game)
          elsif game_stream.new_game?
            discord_webhook_client.send_new_game_alert(game_stream.new_image)
          end
          sqs_client.delete_message({
                                      queue_url: SQS_QUEUE_URL,
                                      receipt_handle: game_stream.receipt_handle
                                    })
        end
      end
    end
    sleep 1
  end

  def run
    @thread = Thread.new { poll_sqs }
  end

  def join
    thread.join
  end

end
