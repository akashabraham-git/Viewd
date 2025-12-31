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
  
end
