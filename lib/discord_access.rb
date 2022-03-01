class DiscordAccess
  VERIFIED_ROLE_NAME = 'verified'
  BANNED_ROLE_NAME = 'banned'
  MODERATOR_ROLE_NAME = 'moderator'
  FAMOUS_ROLE_NAME = '*'

  class << self
    def is_famous?(roles)
      roles.map { |role|
        role.name.downcase }
        .include?(FAMOUS_ROLE_NAME)
    end

    def is_banned?(roles)
      roles.map { |role|
        role.name.downcase }
        .include?(BANNED_ROLE_NAME)
    end

    def is_verified?(roles)
      roles.map { |role|
        role.name.downcase }
        .include?(VERIFIED_ROLE_NAME)
    end

    def is_moderator?(roles)
      roles.map { |role|
        role.name.downcase }
        .include?(MODERATOR_ROLE_NAME)
    end

    def get_verified_role(roles)
      roles
        .select {|e| e.name == VERIFIED_ROLE_NAME}
    end

    def get_banned_role(roles)
      roles
        .select {|e| e.name == BANNED_ROLE_NAME}
    end
  end
end
