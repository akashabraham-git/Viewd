class Connection < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  validate :cannot_follow_self

  def cannot_follow_self
    if follower_id == following_id
      errors.add(:follower_id, "you cannot follow yourself")
    end
  end
  
end
