require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe "validations" do
    it "is invalid if the rating is outside 1 to 5" do
      rating = build(:rating, rating: 6) 
      expect(rating).not_to be_valid
    end
  end

  describe "callbacks" do
    it "marks a movie as watched after a rating is created" do
      member = create(:member)
      movie = create(:movie)
      
      expect {
        create(:rating, member: member, movie: movie)
      }.to change { LibraryEntry.count }.by(1)
      
      entry = LibraryEntry.last
      expect(entry.watched_date).to eq(Date.today)
    end
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Rating.ransackable_attributes).to match_array(["id", "rating", "created_at", "movie_id", "member_id"])
    end

    it "defines ransackable associations" do
      expect(Rating.ransackable_associations).to match_array(["member", "movie"])
    end
  end
end