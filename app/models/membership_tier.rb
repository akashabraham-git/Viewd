class MembershipTier < ApplicationRecord
  has_many :memberships
  has_many :users through :memberships

  enum country: { 
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

  enum badge: {
    gold: 0,
    diamond: 1
  }
end
