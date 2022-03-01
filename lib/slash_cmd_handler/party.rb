require 'scrims'
require 'discord_access'
require 'syndicate_embeds'

class SlashCmdHandler
  class Party
    PARTY_INVITE_KEY = 'party_invite'

    include Helpers

        attr_accessor :bot

    def initialize(bot)
      @bot = bot
    end

    def add_handlers
      bot.application_command(:party).group(nil) do |group|
        group.subcommand(:leave) do |event|
          leave = Scrims::Leave.new($scrims_storage_rom)
          begin
            leave.leave(event.user.id.to_s)
          rescue Scrims::Leave::MemberNotInPartyError => e
          end
          EmbedBuilder.send(:party_leave, event: event, error: e)
        end
        group.subcommand(:invite) do |event|
          puts "#{event.user.id}, #{event.user.username} using invite command"
          party_target = event.options['player']
          next unless ensure_verified_user(event, event.user.roles)
          next unless ensure_ordinary_recipient(event, bot.server(event.server).member(party_target).roles)
          custom_id = "#{PARTY_INVITE_KEY}_#{event.user.id}"
          invitor = event.user.id.to_s
          invitee_channel = event.server.member(party_target).pm
          EmbedBuilder.send(:party_invite_received,
                             channel: invitee_channel,
                             discord_id_list: invitor,
                             custom_id: custom_id)
          EmbedBuilder.send(:party_invite_sent,
                             event: event,
                             discord_id_list: party_target)
        end
        group.subcommand(:list) do |event|
          list_party = Scrims::ListParty.new($scrims_storage_rom)
          begin
            discord_id_list = list_party.list(event.user.id.to_s)
          rescue Scrims::ListParty::EmptyPartyError => e
          end
          EmbedBuilder.send(:party_list,
                            event: event,
                            error: e,
                            discord_id_list: discord_id_list)
        end
      end

      bot.button(custom_id: /^#{PARTY_INVITE_KEY}/) do |event|
        invites = Scrims::Invite.new($scrims_storage_rom)
        invitor = event.interaction.button.custom_id
                               .sub(/^#{PARTY_INVITE_KEY}_/,'')
        event.update_message(content: 'Processing Party...')
        next unless ensure_verified_recipient(event, bot.server(event.server).member(event.user.id).roles)
        begin
          invites.accept(event.user.id.to_s, invitor.to_s)
        rescue Scrims::Invite::MembersInDifferentPartiesError => e
        rescue Scrims::Invite::TooManyMembersError => e
          max_members = SyndicateEmbeds.wrap_strong(Scrims::Invite::DEFAULT_MAX_PARTY_MEMBERS.to_s)
        rescue ROM::SQL::UniqueConstraintError => e
        end

        if e.nil?
          list_party = Scrims::ListParty.new($scrims_storage_rom)
          discord_id_list = list_party.list(invitor.to_s)
        end
        channel = bot.user(invitor).pm
        EmbedBuilder.update(:accept_party_invite,
                            event: event,
                            error: e,
                            discord_id_list: discord_id_list)
        if e.nil?
          EmbedBuilder.send(:party_invite_accepted_acknowledged,
                             event: event,
                             channel: channel,
                             discord_id_list: discord_id_list)
        end
      end
    end
  end
end
