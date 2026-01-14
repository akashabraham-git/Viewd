require 'rails_helper'

RSpec.describe LibraryEntry, type: :model do
  describe "validations" do
    it "is invalid if neither watched nor in watchlist" do
      entry = build(:library_entry, watched_date: nil, in_watchlist: false)
      expect(entry).not_to be_valid
      expect(entry.errors[:base]).to include("Entry must either be in watchlist or have a watched date")
    end
  end
end