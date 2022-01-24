load 'spec_helper.rb'
require 'scrims'

RSpec.describe '#scrims members' do
  let(:party_uuid) { SecureRandom.uuid }
  let(:other_party) {
    {
      party_uuid: SecureRandom.uuid
    }
  }
  let(:party) {
    {
      party_uuid: party_uuid
    }
  }

  before(:each) do
    rom = Scrims::Storage.instance.rom
    @party_repo = Scrims::PartyRepo.new(rom)
    @party_repo.create(party)
    @party_repo.create(other_party)
    @member_repo = Scrims::MemberRepo.new(rom)
  end

  describe 'party' do
    describe 'has no members' do
      it 'members? is false' do
        expect(@party_repo.has_members?(party_uuid)).to be false
      end
    end
    describe 'has n members' do
      before(:each) do
        party_id = @party_repo.find_id_by_party_uuid(party_uuid)
        @member_count = rand(5) + 1
        @members = []
        @member_count.times do
          discord_id = rand(2**32)
          @members.push(discord_id)
          @member_repo.create({ party_id: party_id, discord_id: discord_id })
        end
      end
      it 'members? returns true' do
        expect(@party_repo.has_members?(party_uuid)).to be true
      end
      it 'has n members' do
        expect(@party_repo.member_count(party_uuid)).to eq @member_count
      end
      it 'has the right members' do
        expect(@party_repo.members(party_uuid)
                 .map {|member| member.discord_id } )
          .to eq @members
      end
    end
  end
end
