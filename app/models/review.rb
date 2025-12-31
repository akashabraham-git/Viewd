class Review < ApplicationRecord

  belongs_to :member
  belongs_to :movie
  has_many :likes, as: :likeable, dependent: :destroy

  attr_accessor :current_user_instance

  validates :content, presence: true, length: { minimum: 2, maximum: 5000 }
  
  after_create :mark_as_watched

  def mark_as_watched
    entry = LibraryEntry.find_or_initialize_by(member: current_user_instance.actable, movie: movie)
    if entry.watched_date.nil?
      entry.update(watched_date: Date.today, in_watchlist: false)
    end
  end
end
