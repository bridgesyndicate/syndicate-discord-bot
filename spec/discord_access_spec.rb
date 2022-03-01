require 'spec_helper'
require 'discord_mock'
require 'discord_access'

RSpec.describe '#discord_access' do
  it 'ensure_verified_user is false for a banned user' do
    roles = [DiscordMock::Role.new('banned')]
    expect(DiscordAccess.is_verified?(roles)).to be false
  end

  it 'ensure_verified_user is false for a non verified user' do
    roles = []
    expect(DiscordAccess.is_verified?(roles)).to be false
  end

  it 'ensure_verified_user is true for a verified user' do
    roles = [DiscordMock::Role.new('verified')]
    expect(DiscordAccess.is_verified?(roles)).to be true
  end

  it 'knows a famous user when it sees one' do
    roles = [DiscordMock::Role.new('verified'),
             DiscordMock::Role.new('*')]
    expect(DiscordAccess.is_famous?(roles)).to be true
  end

  it 'knows a moderator user when it sees one' do
    roles = [DiscordMock::Role.new('moderator'),
             DiscordMock::Role.new('*')]
    expect(DiscordAccess.is_moderator?(roles)).to be true
  end

  it 'gets the verified role' do
    roles  = %w/foo bar moderator verified baz/.map do |role|
      DiscordMock::Role.new(role)
    end
    expect(DiscordAccess.get_verified_role(roles).first.name).to eq 'verified'
  end

  it 'gets the banned role' do
    roles  = %w/foo bar banned moderator verified baz/.map do |role|
      DiscordMock::Role.new(role)
    end
    expect(DiscordAccess.get_banned_role(roles).first.name).to eq 'banned'
  end
end
