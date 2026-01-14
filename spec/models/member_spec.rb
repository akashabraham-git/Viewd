require 'rails_helper'

RSpec.describe Member, type: :model do
  describe "callbacks" do
    it "automatically assigns a free membership after creation" do
      create(:membership_tier, name: 'Free', country: :unknown)
      
      member = create(:member)
      
      expect(member.membership).to be_present
      expect(member.membership_tier.name).to eq('Free')
    end
  end

  describe "validations" do
    it "is invalid with a bio longer than 500 characters" do
      long_bio = "a" * 501
      member = build(:member, bio: long_bio)
      expect(member).not_to be_valid 
    end
  end
end