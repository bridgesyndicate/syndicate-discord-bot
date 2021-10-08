class SqsPoller
  attr_accessor :sqs_client, :discord_embed_client, :thread

  SQS_QUEUE_URL = 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_player_messages'

  def initialize
    @sqs_client = Aws::SQS::Client
                    .new(credentials: AwsCredentials.instance.credentials)
    @discord_embed_client = DiscordEmbedClient.instance
  end

  def poll_sqs
    $stdout.sync = true
    while true
      res = sqs_client.receive_message({
                                         queue_url: SQS_QUEUE_URL,
                                         wait_time_seconds: 20
                                       })
      res.messages.each do |message|
        body = JSON.parse(message.body, object_class: OpenStruct)
        if body.event_name == 'MODIFY' and
          !body.dynamodb.new_image.game.game_score.nil?
          discord_embed_client.send_new_game_score(body.dynamodb.new_image)
          sqs_client.delete_message({
                                      queue_url: SQS_QUEUE_URL,
                                      receipt_handle: message[:receipt_handle]
                                    })
        end
      end
      sleep 1
    end
  end

  def run
    thread = Thread.new { poll_sqs }
  end

  def join
    thread.join
  end

end
