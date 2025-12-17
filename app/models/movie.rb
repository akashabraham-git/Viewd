class Movie < ApplicationRecord
  has_many :ratings
  has_many :list_items
  has_many :lists, through: :list_items 
  has_many :likes, as: :likeable
  has_many :reviews
  has_and_belongs_to_many :genres
  has_many :credits
  has_many :cast, through: :credits
  has_many :library_entries
end
