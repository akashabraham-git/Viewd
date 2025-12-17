class List < ApplicationRecord
  belongs_to :user 
  has_many :list_items
  has_many :movies, through: :list_items 
  has_many :likes, as: :likeable
end
