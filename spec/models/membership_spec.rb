require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe "callbacks" do
    it "sets an expiration date for non-Free tiers" do
      pro_tier = create(:membership_tier, name: 'Pro')
      membership = create(:membership, membership_tier: pro_tier)
      
      expect(membership.expires_at).to be_present
      expect(membership.expires_at).to be > Time.current
    end

    it "does not set an expiration date for Free tiers" do
      free_tier = create(:membership_tier, :free)
      membership = create(:membership, membership_tier: free_tier)
      
      expect(membership.expires_at).to be_nil
    end
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      attributes = Membership.ransackable_attributes
      expect(attributes).to match_array(["id","status", "started_at", "expires_at"])
    end

    it "defines ransackable associations" do
      associations = Membership.ransackable_associations
      expect(associations).to match_array(["member", "membership_tier"])
    end
  end
end