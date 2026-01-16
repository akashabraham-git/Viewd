require 'rails_helper'

RSpec.describe Review, type: :model do
  describe "validations" do
    it "is invalid if content is less than 2 characters" do
      review = build(:review, content: "a") 
      expect(review).not_to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:likes) }
    it { should belong_to(:member) }
    it { should belong_to(:movie) }
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Review.ransackable_attributes).to match_array(["id", "content", "created_at", "movie_id", "member_id"])
    end

    it "defines ransackable associations" do
      expect(Review.ransackable_associations).to match_array(["member", "movie"])
    end
  end
end