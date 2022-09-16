require 'scrims'

class SyndicateEmbeds

  # color hex:
  INVISIBLE = '0x2f3137'
  RED = '0xf34653'
  GREEN = '0x58cf5c'
  BLUE = '0x4b7bbf'
  GOLD = '0xffd700'

  # emojis:
  CUMULATIVE_RED_EMOJI = '<:red_1:939769191865679872><:red_2:939769191773384706><:red_3:942565501186490449><:red_4:939769191475593228>'
  CUMULATIVE_BLUE_EMOJI = '<:blue_1:939765626942144573><:blue_2:939765626958938122><:blue_3:939765626577256489><:blue_4:939765626958913556>'

  # content:
  VERIFY_COMMAND = '`/verify:`'
  BARR_COMMAND = '`/barr:`'
  PARTY_LEAVE_COMMAND = '`/party leave:`'
  PARTY_LIST_COMMAND = '`/party list:`'
  PARTY_INVITE_COMMAND = '`/party invite:`'
  DUEL_REQUEST_COMMAND = '`/duel:`'

  # misc:
  MAX_MEMBERS = Scrims::Invite::DEFAULT_MAX_PARTY_MEMBERS.to_s

  def self.wrap_strong(msg)
    '**' + msg + '**'
  end

  EmbedsHash = {
    leaderboard: {
      no_error: {
        content: '`/leaderboard:`',
        title: wrap_strong('The Leaderboard:'),
        color: BLUE
      },
      page_out_of_bounds_error: {
        content: '`/leaderboard:`',
        description: wrap_strong('The page you provided doesn\'t exist.'),
        color: RED
      }
    },
    welcome_message: {
      no_error: {
        title: BotConfig.config.welcome_message_title,
        description: wrap_strong('Click the button below to begin verification.'),
        color: BLUE,
        button_text: 'Verify'
      }
    },
    how_to_verify: {
      no_error: {
        title: BotConfig.config.welcome_message_title,
        description: BotConfig.config.how_to_verify_description,
        image: BotConfig.config.verify_gif,
        color: BLUE
      }
    },
    verify: {
      no_error: {
        content: VERIFY_COMMAND,
        description: wrap_strong('You are now verified!'),
        color: GREEN
      },
      bad_status: {
        content: VERIFY_COMMAND,
        description: wrap_strong('Something went wrong.'),
        color: RED
      },
      invalid_format: {
        content: VERIFY_COMMAND,
        description: wrap_strong('Your code was not in a valid format.'),
        color: RED
      },
      not_found: {
        content: VERIFY_COMMAND,
        description: wrap_strong('Your code was not found or invalid.'),
        color: RED
      }
    },
    ban: {
      no_error: {
        content: BARR_COMMAND,
        description: wrap_strong('This user is now banned: '),
        color: INVISIBLE
      },
      insufficient_permission: {
        content: BARR_COMMAND,
        description: wrap_strong('You do not have permission to perform this command.'),
        color: RED
      },
      syndicate_cant_find_user: {
        content: BARR_COMMAND,
        description: wrap_strong('We could not find this user.'),
        color: RED
      },
      mojang_cant_find_user: {
        content: BARR_COMMAND,
        description: wrap_strong('Mojang could not find this user.'),
        color: RED
      }
    },
    ban_acknowledge: {
      no_error: {
        description: wrap_strong('You have been banned.'),
        color: INVISIBLE
      }
    },
    unban_acknowledge: {
      no_error: {
        description: wrap_strong('You have been unbanned.'),
        color: INVISIBLE
      }
    },
    party_leave: {
      no_error: {
        content: PARTY_LEAVE_COMMAND,
        description: wrap_strong('You have left the party.'),
        color: INVISIBLE
      },
      member_not_in_party_error: {
        content: PARTY_LEAVE_COMMAND,
        description: wrap_strong('You are not in a party.'),
        color: RED
      },
      member_in_queue_error: {
        content: PARTY_LEAVE_COMMAND,
        description: wrap_strong('You must /dq before you can leave the party.'),
        color: RED
      }
    },
    party_list: {
      no_error: {
        content: PARTY_LIST_COMMAND,
        description: wrap_strong('Your party:') + "\n",
        color: INVISIBLE
      },
      empty_party_error: {
        content: PARTY_LIST_COMMAND,
        description: wrap_strong('Your party is empty.'),
        color: RED
      }
    },
    party_invite_sent: {
      no_error: {
        content: PARTY_INVITE_COMMAND,
        description: wrap_strong('Your party invite has been sent to '),
        color: INVISIBLE
      },
      banned_sender: {
        content: PARTY_INVITE_COMMAND,
        description: wrap_strong('You are banned.'),
        color: RED
      },
      unverified_sender: {
        content: PARTY_INVITE_COMMAND,
        description: wrap_strong('You must be verified to use this command.'),
        color: RED
      },
      famous_recipient: {
        content: PARTY_INVITE_COMMAND,
        description: wrap_strong('You cannot party this player.'),
        color: RED
      }
    },
    party_invite_received: {
      no_error: {
        button_text: 'Accept',
        description: wrap_strong('You have received a party invite from '),
        color: INVISIBLE
      }
    },
    party_invite_accepted_acknowledged: {
      no_error: {
        description: wrap_strong('Your party invite has been accepted. Your party:') + "\n",
        color: INVISIBLE
      }
    },
    accept_party_invite: {
      no_error: {
        description: wrap_strong('You have accepted an invite. Your party:') + "\n",
        color: INVISIBLE
      },
      banned_recipient: {
        description: wrap_strong('You are banned.'),
        color: RED
      },
      unverified_recipient: {
        description: wrap_strong('You must be verified to accept this invite.'),
        color: RED
      },
      members_in_different_parties_error: {
        description: wrap_strong('This player is in a different party.'),
        color: RED
      },
      member_in_queue_error: {
        description: wrap_strong('You or the player that invited you is currently queued.'),
        color: RED
      },
      too_many_members_error: {
        description: wrap_strong('The maximum party size is ' + MAX_MEMBERS + '.'),
        color: RED
      },
      unique_constraint_error: {
        description: wrap_strong('You cannot party yourself. You will go blind.'),
        color: RED
      }
    },
    duel_request_sent: {
      no_error: {
        content: DUEL_REQUEST_COMMAND,
        fields: {
          red: CUMULATIVE_RED_EMOJI,
          blue: CUMULATIVE_BLUE_EMOJI
        },
        title: wrap_strong('Your duel request has been sent.'),
        color: INVISIBLE
      },
      party_sizes_unequal_error: {
        content: DUEL_REQUEST_COMMAND,
        description: wrap_strong('The party sizes are unequal.'),
        color: RED
      },
      banned_sender: {
        content: DUEL_REQUEST_COMMAND,
        description: wrap_strong('You are banned.'),
        color: RED
      },
      unverified_sender: {
        content: DUEL_REQUEST_COMMAND,
        description: wrap_strong('You must be verified to use this command.'),
        color: RED
      },
      famous_recipient: {
        content: DUEL_REQUEST_COMMAND,
        description: wrap_strong('You cannot duel this player.'),
        color: RED
      }
    },
    duel_request: {
      no_error: {
        fields: {
          red: CUMULATIVE_RED_EMOJI,
          blue: CUMULATIVE_BLUE_EMOJI
        },
        button_text: 'Accept',
        title: wrap_strong('You have received a duel request.'),
        color: INVISIBLE
      }
    },
    accept_duel_request: {
      no_error: {
        fields: {
          red: CUMULATIVE_RED_EMOJI,
          blue: CUMULATIVE_BLUE_EMOJI
        },
        title: wrap_strong('You have accepted this duel request.'),
        color: INVISIBLE
      },
      banned_recipient: {
        description: wrap_strong('You are banned.'),
        color: RED
      },
      unverified_recipient: {
        description: wrap_strong('You must be verified to accept this invite.'),
        color: RED
      },
      double_lock_error: {
        description: wrap_strong('You cannot duel yourself. You will go blind.'),
        color: RED
      },
      expired_duel_error: {
        description: wrap_strong('This duel has expired.'),
        color: RED
      },
      locked_player_error: {
        description: wrap_strong('A player from this duel is in another game.'),
        color: RED
      },
      member_in_queue_error: {
        description: wrap_strong('A player from this duel is currently queued.'),
        color: RED
      },
      missing_duel_error: {
        description: wrap_strong('No such duel exists.'),
        color: RED
      },
      invalid_acceptor_error: {
        description: wrap_strong('You are not a valid acceptor of this duel.'),
        color: RED
      },
      bad_status: {
        description: wrap_strong('Something went wrong.'),
        color: RED
      }
    }
  }

end
