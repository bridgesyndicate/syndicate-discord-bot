def ensure_verified_user(event)
  unless DiscordAccess.is_verified?(event.user.roles)
    event.respond(content: "You must be verified to use this command.")
  else
    true
  end
end

def ensure_verified_acceptor(bot, event, acceptor_id)
  unless DiscordAccess.is_verified?(bot.server(event.server).member(acceptor_id).roles)
    event.respond(content: "The person you invited must be verified to accept.")
  else
    true
  end
end

class DiscordAccess
  VERIFIED_ROLE_NAME = 'verified'

  def self.is_verified?(roles)
    roles.map { |role|
      role.name.downcase }
      .include?(VERIFIED_ROLE_NAME)
  end

  def self.get_verified_role(roles)
    roles
      .select {|e| e.name == VERIFIED_ROLE_NAME}
  end
end
