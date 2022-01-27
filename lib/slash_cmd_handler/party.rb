require 'scrims'

class SlashCmdHandler
  class Party
    PARTY_INVITE_KEY = 'party_invite'

    def self.init(bot)
      bot.application_command(:party).group(nil) do |group|
        group.subcommand(:leave) do |event|
          leave = Scrims::Leave.new($scrims_storage_rom)
          leave.leave(event.user.id)
          event.respond(content: "You have left the party.")
        end
        group.subcommand(:invite) do |event|
          party_target = event.options['player']
          custom_id = "#{PARTY_INVITE_KEY}_#{event.user.id}"
          event.server.member(party_target).pm.send_embed() do |embed, view|
            embed.description = "Party Request from <@#{event.user.id}>"
            view.row do |r|
              r.button(
                label: 'Accept',
                style: :primary,
                custom_id: custom_id
              )
            end
          end
          event.respond(content: "Your party request has been sent.")
        end
        group.subcommand(:list) do |event|
          list_party = Scrims::ListParty.new($scrims_storage_rom)
          party_list = list_party.list(event.user.id)
          event.respond(content: "Your party: #{format_discord_id_mention_list(party_list)}")
        end
      end

      bot.button(custom_id: /^#{PARTY_INVITE_KEY}/) do |event|
        invites = Scrims::Invites.new($scrims_storage_rom)
        invitee_discord_id = event.interaction.button.custom_id
                               .sub(/^#{PARTY_INVITE_KEY}_/,'')
        invites.accept(event.user.id, invitee_discord_id)
        list_party = Scrims::ListParty.new($scrims_storage_rom)
        party_list = list_party.list(event.user.id)
        event.update_message(content: "You accepted an invite. Your party: #{format_discord_id_mention_list(party_list)}")
        bot.user(invitee_discord_id).pm("Your invite to #{format_discord_mention(event.user.id)} was accepted.")
      end
    end
  end
end
