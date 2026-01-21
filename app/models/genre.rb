class Genre < ApplicationRecord
  has_and_belongs_to_many :movies

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["name", "id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["movies"]
  end
end
