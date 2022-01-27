class MockDiscordResolver
  def resolve_name_from_discord_id(discord_id)
    Faker::Internet.username
  end
end
