require 'rails_helper'

RSpec.describe Like, type: :model do
  describe "associations" do
    it { should belong_to(:member) }
    it { should belong_to(:likeable) }
  end

  describe "associated_movie" do
    it "returns the movie when the likeable is a Movie" do
      movie = create(:movie)
      like = create(:like, :for_movie, likeable: movie)
      expect(like.associated_movie).to eq(movie) 
    end

    it "returns the parent movie when the likeable is a Review" do
      movie = create(:movie)
      review = create(:review, movie: movie)
      like = create(:like, :for_review, likeable: review)
      expect(like.associated_movie).to eq(movie) 
    end

    it "returns nil when the likeable_type is neither Movie nor Review" do
      movie = create(:movie)
      like = create(:like, :for_movie, likeable: movie)
      like.update_column(:likeable_type, 'UnknownType')
      like.update_column(:likeable_id, 999)
      expect(like.associated_movie).to be_nil
    end
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Like.ransackable_attributes).to match_array(["id", "likeable_type", "likeable_id"])
    end

    it "defines ransackable associations" do
      expect(Like.ransackable_associations).to match_array(["member", "likeable"])
    end
  end

end