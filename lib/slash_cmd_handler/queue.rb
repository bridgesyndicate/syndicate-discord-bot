require 'scrims'
require 'discord_access'
require 'syndicate_embeds'
require 'syndicate_web_service'

class SlashCmdHandler
  class Queue

    include Helpers

    attr_accessor :bot, :queue, :member_repo, :party_repo, :lock_repo

    def initialize(bot, queue)
      @bot = bot
      @queue = queue
      @queue.elo_resolver = EloResolver.new
      @member_repo = Scrims::MemberRepo.new($rom)
      @party_repo = Scrims::Storage::Party.new($rom)
      @lock_repo = Scrims::Locks.new($rom)
    end

    def add_handlers
      bot.application_command(:q) do |event|
        syn_logger "Request to queue from #{event.user.id}, #{event.user.username}"
        next unless ensure_queuer_roles(event, roles_for_member(event.user))
        discord_id = event.user.id.to_s
        if queue.member_repo.discord_id_in_party?(discord_id)
          party_id = member_repo.get_party(discord_id)
          party = party_repo.by_pk(party_id).first
          party = party.to_h.transform_keys{|key| key == :id ? :party_id : key}
          party_size = party_repo.member_count(party_id)
          entity = party
        else
          player = {
            discord_id: event.user.id.to_s,
            discord_username: event.user.username,
          }
          party_size = 1
          entity = player
        end
        
        begin
          queue_entity(entity, event)
        rescue Scrims::Queue::AlreadyQueuedError => e
        rescue Scrims::Queue::LockedPlayerError => e
          event.respond(content: "You cannot /q while queued or in a game.")
        end
        DelayedWorker.new(Scrims::MAX_QUEUE_TIME) do
          game_maker = GameMaker.new(web_service_klass: SyndicateWebService,
                                     party_repo: party_repo,
                                     lock_repo: lock_repo,
                                     elo_resolver: queue.elo_resolver)
          game_maker.from_match(queue.process_queue(party_size=party_size))
        end.run
        game_maker = GameMaker.new(web_service_klass: SyndicateWebService,
                                   party_repo: party_repo,
                                   lock_repo: lock_repo,
                                   elo_resolver: queue.elo_resolver)
        game_maker.from_match(queue.process_queue(party_size=party_size))
      end
    end

    def queue_entity(entity, event)
      if entity.has_key?(:discord_id)
        queue.queue_player(entity)
        event.respond(content: "#{event.user.username} is queued. Type /dq to dequeue.")
      else
        queue.queue_party(entity)
        event.respond(content: "#{event.user.username}'s party is queued. Type /dq to dequeue.")
      end
    end
  end
end
