require 'rails_helper'

RSpec.describe Connection, type: :model do
  describe "associations" do
    it { should belong_to(:follower).class_name('Member') }
    it { should belong_to(:following).class_name('Member') }
  end

  describe "validations" do
    it "prevents duplicate connections between the same members" do
      existing = create(:connection)
      
      duplicate = build(:connection, 
                        follower: existing.follower, 
                        following: existing.following)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:follower_id]).to include("connection already exists")
    end 
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      attributes = Connection.ransackable_attributes
      expect(attributes).to match_array(["id", "follower_id", "following_id", "created_at"])
    end

    it "defines ransackable associations" do
      associations = Connection.ransackable_associations
      expect(associations).to match_array(["follower", "following"])
    end
  end

end