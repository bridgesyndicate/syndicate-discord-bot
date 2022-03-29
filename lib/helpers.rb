DISCORD_SERVER_ID=749164130304262204 #TODO: make this grab from the config, without breaking every spec
STARTING_ELO=1000
UUID_REGEX = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/

def format_discord_id_mention_list(ids)
  ids
    .map { |id| format_discord_id_mention(id) }
    .join("\n")
end

def format_discord_id_mention(id)
  '<@' + id.to_s + '>'
end
