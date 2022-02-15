def ensure_verified_user(event)
  if DiscordAccess.is_banned?(event.user.roles)
    event.respond(content: "You are banned.")
  else
    if
      !DiscordAccess.is_verified?(event.user.roles)
      event.respond(content: "You must be verified to use this command.")
    else
      true
    end
  end
end

def ensure_ordinary_user(bot, event, duel_target, type)
  if !DiscordAccess.is_famous?(event.user.roles) and DiscordAccess.is_famous?(bot.server(event.server).member(duel_target).roles)
    event.respond(content: "This player cannot be #{type.to_s}.")
    return false
  else
    true
  end
end

def ensure_moderator(event)
  if DiscordAccess.is_moderator?(event.user.roles)
    true
  else
    event.respond(content: "This command is not available.")
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
  BANNED_ROLE_NAME = 'banned'
  MODERATOR_ROLE_NAME = 'moderator'
  FAMOUS_ROLE_NAME = '*'

  def self.is_famous?(roles)
    roles.map { |role|
      role.name.downcase }
      .include?(FAMOUS_ROLE_NAME)
  end

  def self.is_banned?(roles)
    roles.map { |role|
      role.name.downcase }
      .include?(BANNED_ROLE_NAME)
  end

  def self.is_verified?(roles)
    roles.map { |role|
      role.name.downcase }
      .include?(VERIFIED_ROLE_NAME)
  end

  def self.is_moderator?(roles)
    roles.map { |role|
      role.name.downcase }
      .include?(MODERATOR_ROLE_NAME)
  end

  def self.get_verified_role(roles)
    roles
      .select {|e| e.name == VERIFIED_ROLE_NAME}
  end

  def self.get_banned_role(roles)
    roles
      .select {|e| e.name == BANNED_ROLE_NAME}
  end
end
