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
end