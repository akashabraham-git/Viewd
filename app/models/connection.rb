class Connection < ApplicationRecord
  belongs_to :follower, class_name: "Member"
  belongs_to :following, class_name: "Member"

  validate :cannot_follow_self

  after_commit :notify_connection, on: :create

  private

  def notify_connection
    puts "#{follower.user.username} just started following #{following.user.username}!"
  end

  def cannot_follow_self
    if follower_id == following_id
      errors.add(:follower_id, "you cannot follow yourself")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "follower_id", "following_id", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["follower", "following"]
  end
  
end
