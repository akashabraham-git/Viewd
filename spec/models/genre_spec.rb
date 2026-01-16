require 'rails_helper'

RSpec.describe Genre, type: :model do
  describe "associations" do
    it { should have_and_belong_to_many(:movies) }
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Genre.ransackable_attributes).to match_array(["name", "id"])
    end

    it "defines ransackable associations" do
      expect(Genre.ransackable_associations).to eq(["movies"])
    end
  end
end