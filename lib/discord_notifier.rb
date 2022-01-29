class Notifier
  attr_accessor :bot, :game_json, :event

  def initialize(bot, event)
    @bot = bot
    @game_json = game_json
    @event = event
  end

  def notify_opponents(discord_ids, custom_id)
    discord_ids.each do |discord_id|
      send_embed(discord_id, custom_id)
    end
  end

  def send_embed(discord_id, custom_id)
    event.server.member(discord_id).pm.send_embed() do |embed, view|
      embed.description = "Duel Request from <@#{event.user.id}>"
      view.row do |r|
        r.button(
          label: 'Accept',
          style: :primary,
          custom_id: custom_id
          )
      end
    end
  end
end