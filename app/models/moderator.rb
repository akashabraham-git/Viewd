class Moderator < ApplicationRecord
  has_one :user, as: :actable, dependent: :destroy
  accepts_nested_attributes_for :user


  def self.ransackable_attributes(auth_object = nil)
    ["id","created_at", "employee_number","department"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end