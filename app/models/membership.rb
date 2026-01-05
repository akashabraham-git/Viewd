class Membership < ApplicationRecord
  belongs_to :member
  belongs_to :membership_tier

  enum :status, { active: 0, cancelled: 1, expired: 2 }

  before_create :set_default_dates

  private

  def set_default_dates
    self.started_at ||= Time.current
    if membership_tier && membership_tier.name != 'Free'
      self.expires_at ||= 1.month.from_now
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "status", "started_at", "expires_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["member", "membership_tier"]
  end

end