class Cast < ApplicationRecord
  has_many :credits, dependent: :destroy
  has_many :movies, through: :credits
end
