class Review < ApplicationRecord
  include Watchable

  belongs_to :member
  belongs_to :movie
  has_many :likes, as: :likeable

  validates :content, presence: true, length: { minimum: 2, maximum: 5000 }
  
  after_create :mark_as_watched
end
