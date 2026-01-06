class LibraryEntry < ApplicationRecord
  belongs_to :movie
  belongs_to :member

  validates :movie_id, uniqueness: { 
    scope: :member_id, 
    message: "already in this member's library" 
  }

  validate :must_have_status

  private

  def must_have_status
    if watched_date.nil? && !in_watchlist
      errors.add(:base, "Entry must either be in watchlist or have a watched date")
    end
  end

  scope :watchlist, -> { where(in_watchlist: true) }
  scope :watched, -> { where.not(watched_date: nil) }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "in_watchlist", "watched_date" , "movie_id", "member_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["member", "movie"]
  end
end




