class MockPartyRepo
  attr_accessor :members
  def initialize(members)
    @members = members
  end

  def with_members(party_id)
    [OpenStruct.new({ members: members[party_id] })]
  end
end

class OpenStruct
  def to_a
    self
  end
end
