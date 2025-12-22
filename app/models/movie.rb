class Movie < ApplicationRecord
  has_many :ratings
  has_many :likes, as: :likeable
  has_many :reviews
  has_and_belongs_to_many :genres
  has_many :credits
  has_many :cast_members, through: :credits, source: :cast
  has_many :library_entries

  def average_rating
    ratings.average(:rating).to_f.round(1)
  end
end
