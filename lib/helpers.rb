DISCORD_SERVER_ID=BotConfig.config.discord_guild_id
STARTING_ELO=1000
UUID_REGEX = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
POST='POST'
GET='GET'
DELETE='DELETE'

def format_discord_id_mention_list(ids)
  ids
    .map { |id| format_discord_id_mention(id) }
    .join("\n")
end

def format_discord_id_mention(id)
  '<@' + id.to_s + '>'
end

def syn_logger(msg)
  s = 0
  caller.each_with_index { |c, i| s = d if c.include?(__method__.to_s) }
  puts "#{caller[s]}: #{msg}" if SYNDICATE_ENV != 'test'
end

def now
  Time.now
end
