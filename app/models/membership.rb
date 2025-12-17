class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :membership_tier

  enum status: {active: 0, cancelled: 1, expired: 2}

  before_create :set_default_dates

  def set_default_dates
    tier = MembershipTiers.find_by(id: tier_id)
    self.started_at = Time.current unless started_at.present?
    if membership_tier.name != 'Free'
      self.expires_at = 1.month.from_now unless expires_at.present? 
    end
  end


end
