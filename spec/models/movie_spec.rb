require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe "instance methods" do
    it "calculates the correct average rating" do
      movie = create(:movie)
      create(:rating, movie: movie, member: create(:member), rating: 5)
      create(:rating, movie: movie, member: create(:member), rating: 3)
      create(:rating, movie: movie, member: create(:member), rating: 4)

      expect(movie.average_rating).to eq(4.0)
    end

    it "returns 0.0 if there are no ratings" do
      movie = build(:movie)
      expect(movie.average_rating).to eq(0.0) 
    end
  end

  describe "associations" do
    it { should have_many(:ratings).dependent(:destroy) }
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_and_belong_to_many(:genres) }
    it { should have_many(:credits).dependent(:destroy) }
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      attributes = Movie.ransackable_attributes
      expect(attributes).to match_array(["title", "status", "language", "release_date", "runtime", "tmdb_id", "created_at"])
    end

    it "defines ransackable associations" do
      associations = Movie.ransackable_associations
      expect(associations).to match_array(["genres", "casts", "credits"])
    end
  end

end