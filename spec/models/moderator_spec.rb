require 'rails_helper'

RSpec.describe Moderator, type: :model do
  describe "associations" do
    it { should have_one(:user).dependent(:destroy) }
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(Moderator.ransackable_attributes).to match_array(["id", "created_at", "employee_number", "department"])
    end

    it "defines ransackable associations" do
      expect(Moderator.ransackable_associations).to eq(["user"])
    end
  end
end