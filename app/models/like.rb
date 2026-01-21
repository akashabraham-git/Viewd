class Like < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :member
  belongs_to :likeable, polymorphic: true

  scope :movie_likes, -> { where(likeable_type: 'Movie') }
  scope :review_likes, -> { where(likeable_type: 'Review') }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "likeable_type", "likeable_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["member", "likeable"]
  end

  def associated_movie
    if likeable_type == 'Movie'
      likeable
    elsif likeable_type == 'Review'
      likeable.movie
    end
  end
end
