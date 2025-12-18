class Membership < ApplicationRecord
  belongs_to :user
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
end