class Movie < ApplicationRecord
  has_many :ratings, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :genres
  has_many :credits, dependent: :destroy
  has_many :cast_members, through: :credits, source: :cast
  has_many :library_entries, dependent: :destroy
  accepts_nested_attributes_for :credits, allow_destroy: true, reject_if: :all_blank

  scope :recent, -> { where('release_date > ?', 1.year.ago) }
  scope :released, -> { where(status: 'released') }

  enum :status, {
    released: 0,
    unreleased: 1
  }

  def average_rating
    ratings.average(:rating).to_f.round(1)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["title", "status", "language", "release_date", "runtime", "tmdb_id", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["genres", "casts", "credits"]
  end
end
