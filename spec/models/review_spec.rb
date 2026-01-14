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
end