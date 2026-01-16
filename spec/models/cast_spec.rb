require 'rails_helper'

RSpec.describe Cast, type: :model do
  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Cast.ransackable_attributes).to match_array(["id", "name", "tmdb_id"])
    end

    it "defines ransackable associations" do
      expect(Cast.ransackable_associations).to match_array(["movies", "credits"])
    end
  end
end