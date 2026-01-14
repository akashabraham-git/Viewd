require 'rails_helper'

RSpec.describe MembershipTier, type: :model do
  describe "callbacks" do
    it "sets the badge to gold for Pro tiers" do
      tier = create(:membership_tier, :pro)
      expect(tier.badge).to eq("gold")
    end

    it "sets the badge to diamond for Patron tiers" do
      tier = create(:membership_tier, :patron)
      expect(tier.badge).to eq("diamond")
    end

    it "does not set a badge for other tier names" do
      tier = create(:membership_tier, :free)
      expect(tier.badge).to be_nil
    end
  end

end