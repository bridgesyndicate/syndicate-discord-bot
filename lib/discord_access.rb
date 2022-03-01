require 'syndicate_embeds'

def ensure_verified_user(embed_builder, event)
  if DiscordAccess.is_banned?(event.user.roles)
    embed_builder.send(:party_invite_sent, event: event, error: :banned_sender)
    false
  else
    if
      !DiscordAccess.is_verified?(event.user.roles)
      embed_builder.send(:party_invite_sent, event: event, error: :unverified_sender)
      false
    else
      true
    end
  end
end

def ensure_ordinary_recipient(embed_builder, bot, event, recipient, type)
  if !DiscordAccess.is_famous?(event.user.roles) and DiscordAccess.is_famous?(bot.server(event.server).member(recipient).roles)
    embed_builder.send(type, event: event, error: :famous_recipient)
    false
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

def ensure_verified_recipient(embed_builder, bot, event, recipient)
  if DiscordAccess.is_banned?(bot.server(event.server).member(recipient).roles)
    embed_builder.send(:party_invite_sent, event: event, error: :banned_recipient)
    false
  else
    if
      !DiscordAccess.is_verified?(bot.server(event.server).member(recipient).roles)
      embed_builder.send(:party_invite_sent, event: event, error: :unverified_recipient)
      false
    else
      true
    end
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
