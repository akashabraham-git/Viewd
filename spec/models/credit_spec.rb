require 'rails_helper'

RSpec.describe Credit, type: :model do
  describe "callbacks" do
    it "normalizes the character name by squishing and titleizing" do
      credit = create(:credit, character: "  iron   man  ")
      expect(credit.character).to eq("Iron Man")
    end

    it "does nothing if character is nil" do
      credit = create(:credit, character: nil)
      expect(credit.character).to be_nil
    end
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Credit.ransackable_attributes).to match_array(["cast_id", "movie_id", "character", "job"])
    end

    it "defines ransackable associations" do
      expect(Credit.ransackable_associations).to match_array(["cast", "movie"])
    end
  end
end