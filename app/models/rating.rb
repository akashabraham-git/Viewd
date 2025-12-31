class Rating < ApplicationRecord

  belongs_to :member
  belongs_to :movie

  attr_accessor :current_user_instance

  validates :member_id, uniqueness: { scope: :movie_id }
  validates :rating, presence: true, inclusion: { in: 1..5 }

  after_create :mark_as_watched

  def mark_as_watched
    entry = LibraryEntry.find_or_initialize_by(member: current_user_instance.actable, movie: movie)
    if entry.watched_date.nil?
      entry.update(watched_date: Date.today, in_watchlist: false)
    end
  end
end
