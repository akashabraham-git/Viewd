require 'rails_helper'

RSpec.describe LibraryEntry, type: :model do
  describe "validations" do
    it "is invalid if neither watched nor in watchlist" do
      entry = build(:library_entry, watched_date: nil, in_watchlist: false)
      expect(entry).not_to be_valid
      expect(entry.errors[:base]).to include("Entry must either be in watchlist or have a watched date")
    end
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      attributes = LibraryEntry.ransackable_attributes
      expect(attributes).to match_array(["id", "in_watchlist", "watched_date" , "movie_id", "member_id"])
    end

    it "defines ransackable associations" do
      associations = LibraryEntry.ransackable_associations
      expect(associations).to match_array(["member", "movie"])
    end
  end
end