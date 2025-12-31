class Movie < ApplicationRecord
  has_many :ratings, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :genres
  has_many :credits, dependent: :destroy
  has_many :cast_members, through: :credits, source: :cast
  has_many :library_entries, dependent: :destroy
  accepts_nested_attributes_for :credits, allow_destroy: true, reject_if: :all_blank

  def average_rating
    ratings.average(:rating).to_f.round(1)
  end
end
