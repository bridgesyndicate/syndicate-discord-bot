require 'scrims'

class SyndicateEmbeds

  # color hex:
  INVISIBLE = '0x2f3137'
  RED = '0xf34653'
  GREEN = '0x58cf5c'

  # emojis:
  CUMULATIVE_RED_EMOJI = '<:red_1:939769191865679872><:red_2:939769191773384706><:red_3:942565501186490449><:red_4:939769191475593228>'
  CUMULATIVE_BLUE_EMOJI = '<:blue_1:939765626942144573><:blue_2:939765626958938122><:blue_3:939765626577256489><:blue_4:939765626958913556>'

  # content:
  VERIFY_COMMAND = '`/verify:`'
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
