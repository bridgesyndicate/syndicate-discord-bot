require 'spec_helper'
require 'user'

describe '#user' do
  let(:discord_id) { rand(2**32).to_s }
  let(:minecraft_uuid) { SecureRandom.uuid }
  let(:http_reponse_json) { File.read('spec/mocks/syndicate-web-service/user/by-discord-id/get/200.json') }

  before(:each) do
    stub_request(:get, %r{/Prod/auth/user/by-discord-id})
      .to_return(status: 200, body: http_reponse_json)
  end

  describe 'new' do
    it 'requires a discord id when making a user' do
      expect {
        User.new
      }.to raise_error User::DiscordIdRequiredError
    end

    describe 'web service call fails' do
      before(:each) do
        stub_request(:get, %r{/Prod/auth/user/by-discord-id})
          .to_timeout
      end

      it 'fails to instantiate' do
        expect {
          User.new(discord_id: discord_id)
        }.to raise_error User::CouldNotPopulateUser
      end
    end

    describe 'web service returns 400' do
      before(:each) do
        stub_request(:get, %r{/Prod/auth/user/by-discord-id})
          .to_return(status: 400, body: nil)
      end

      it 'returns bad request' do
        expect {
          User.new(discord_id: discord_id)
        }.to raise_error User::BadRequest
      end
    end

    describe 'web service returns 404' do
      before(:each) do
        stub_request(:get, %r{/Prod/auth/user/by-discord-id})
          .to_return(status: 404, body: nil)
      end

      it 'returns not registered' do
        expect {
          User.new(discord_id: discord_id)
        }.to raise_error User::UnregisteredUser
      end

      describe 'discord id does not exist' do
        it 'fails to instantiate' do
          expect {
            User.new(discord_id: nil)
          }.to raise_error User::DiscordIdRequiredError
        end
      end
    end
  end

  describe 'the cache' do
    it 'the class has access to LRU cache' do
      expect(User.new(discord_id: discord_id).cache).to be_a LruRedux::Cache
    end

    it 'the cache works' do
      user = User.new(discord_id: discord_id)
      user.cache[:foo] = 'bar'
      expect(user.cache[:foo]).to eq 'bar'
    end

    it 'instances of User share the cache' do
      user = User.new(discord_id: discord_id)
      user.cache[:foo] = 'bar'
      user2 = User.new(discord_id: discord_id)
      expect(user2.cache[:foo]).to eq 'bar'
    end

    it 'can cache a Hash with a minecraft uuid' do
      user = User.new(discord_id: discord_id)
      properties = user.properties
      user2 = User.new(discord_id: discord_id)
      expect(user.properties[:minecraft_uuid])
        .to be_a String
      expect(user.properties[:minecraft_uuid])
        .to eq user2.properties[:minecraft_uuid]
    end

    it 'a valid user is verified' do
      user = User.new(discord_id: discord_id)
      expect(user.is_verified?).to be true
    end

    it 'a user is not banned by default' do
      user = User.new(discord_id: discord_id)
      expect(user.is_banned?).to be nil
    end

    it 'a banned user has the banned property' do
      user = User.new(discord_id: discord_id)
      user.ban
      user2 = User.new(discord_id: discord_id)
      expect(user2.is_banned?).to be true
    end

    it 'an unbanned user no longer has the banned property' do
      user = User.new(discord_id: discord_id)
      user.ban
      user2 = User.new(discord_id: discord_id)
      user.unban
      user3 = User.new(discord_id: discord_id)
      expect(user3.is_banned?).to be nil
    end

  end
end
