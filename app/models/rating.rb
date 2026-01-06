class Rating < ApplicationRecord

  belongs_to :member
  belongs_to :movie

  attr_accessor :current_user_instance

  validates :member_id, uniqueness: { scope: :movie_id }
  validates :rating, presence: true, inclusion: { in: 1..5 }

  after_create :mark_as_watched

  def mark_as_watched
    entry = LibraryEntry.find_or_initialize_by(member: member, movie: movie)
    if entry.watched_date.nil?
      entry.update(watched_date: Date.today, in_watchlist: false)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "rating", "created_at", "movie_id", "member_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["member", "movie"]
  end
end
