class Rating < ApplicationRecord
  include Watchable

  belongs_to :user
  belongs_to :movie


  validates :user_id, uniqueness: { scope: :movie_id }
  validates :rating, presence: true, inclusion: { in: 1..5 }

  after_create :mark_as_watched
end
