class Notifier
  attr_accessor :bot

  def initialize(bot)
    @bot = bot
  end

  def notify_opponents(discord_ids)
    discord_ids.each do |discord_id|
      send_message(discord_id)
    end
  end

  def send_message(discord_id)
    # get embed
    # send to player
  end

  def build_embed(event)
    # custom_id = "duel_accept_uuid_" + JSON.parse(game_json)['uuid']
    # event.server.member(red_team_discord_ids.first).pm.send_embed() do |embed, view|
    #   embed.description = "Duel Request from <@#{event.user.id}>"
    #   view.row do |r|
    #     r.button(
    #       label: 'Accept',
    #       style: :primary,
    #       custom_id: custom_id
    #     )
    #   end
    # end
  end

end