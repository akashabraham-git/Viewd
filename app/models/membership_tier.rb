class MembershipTier < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships

  before_create :set_badge


  scope :free, -> { where('name ILIKE ?', "Free") }
  scope :pro, -> { where('name ILIKE ?', "Pro") }
  scope :patron, -> { where('name ILIKE ?', "Patron") }

  def set_badge
    if self.name == "Pro"
      self.badge = :gold
    elsif self.name == "Patron"
      self.badge = :diamond
    end
  end


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

  enum :badge, {
    gold: 0,
    diamond: 1
  }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "price", "country", "id", "badge"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["memberships"]
  end

end
