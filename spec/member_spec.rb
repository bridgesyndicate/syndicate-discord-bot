require 'spec_helper'
require 'scrims'

RSpec.describe '#scrims members' do
  let(:other_party) {
    {
      created_at: Time.now - (86400 * 30)
    }
  }
  let(:party) {
    {
      created_at: Time.now
    }
  }

  before(:each) do
    rom = Scrims::Storage.new.rom
    @party_repo = Scrims::PartyRepo.new(rom)
    @party = @party_repo.create(party)
    @party_repo.create(other_party)
    @member_repo = Scrims::MemberRepo.new(rom)
  end

  describe 'party' do
    describe 'has no members' do
      it 'members? is false' do
        expect(@party_repo.has_members?(@party.id)).to be false
      end
    end
    describe 'has n members' do
      before(:each) do
        @member_count = rand(5) + 1
        @members = []
        @member_count.times do
          discord_id = rand(2**32)
          @members.push(discord_id.to_s)
          @member_repo.create(
                              { party_id: @party.id,
                                discord_id: discord_id,
                                created_at: Time.now
                              })
        end
      end
      it 'members? returns true' do
        expect(@party_repo.has_members?(@party.id)).to be true
      end
      it 'has n members' do
        expect(@party_repo.member_count(@party.id)).to eq @member_count
      end
      it 'has the right members' do
        expect(@party_repo.with_members(@party.id)
                 .first
                 .members
                 .map {|member| member.discord_id } )
          .to eq @members
      end
    end
  end
end
