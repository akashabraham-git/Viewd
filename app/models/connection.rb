class Connection < ApplicationRecord

  acts_as_paranoid

  belongs_to :follower, class_name: "Member"
  belongs_to :following, class_name: "Member"

  validates :follower_id, uniqueness: { 
    scope: :following_id, 
    message: "connection already exists" 
  }

  private

  def self.ransackable_attributes(auth_object = nil)
    ["id", "follower_id", "following_id", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["follower", "following"]
  end
  
end
