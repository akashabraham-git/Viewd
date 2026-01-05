class Cast < ApplicationRecord
  has_many :credits, dependent: :destroy
  has_many :movies, through: :credits

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["movies", "credits"]
  end
end
