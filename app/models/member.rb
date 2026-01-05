class Member < ApplicationRecord
  has_one :user, as: :actable, dependent: :destroy
  has_one :membership, dependent: :destroy
  has_one :membership_tier, through: :membership
  has_one_attached :profile_picture
  has_many :incoming_connections, class_name: "Connection", foreign_key: "following_id", dependent: :destroy
  has_many :followers, through: :incoming_connections, source: :follower
  has_many :outgoing_connections, class_name: "Connection", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :outgoing_connections, source: :following
  has_many :library_entries, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  accepts_nested_attributes_for :user

  enum :country, { 
    unknown: 0, 
    usa: 1, 
    india: 2, 
    uk: 3, 
    canada: 4, 
    australia: 5,
    germany: 6,
    france: 7,
    japan: 8,
    brazil: 9 
  }

  validates :bio, length: { maximum: 500 }
  
  after_create :assign_default_membership

  def assign_default_membership
    tier = MembershipTier.find_by(name: 'Free', country: :unknown)
    if tier
      create_membership(membership_tier: tier, status: :active)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "bio", "country", "created_at"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["user", "membership", "following", "followers", "active_connections"]
  end

end
