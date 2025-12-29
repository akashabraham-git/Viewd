class User < ApplicationRecord
  belongs_to :actable, polymorphic: true
  delegate :bio, :country, to: :actable, allow_nil: true

  validates :username, presence: true, uniqueness: true, length: {minimum: 3, maximum: 20}, format: {with: /\A[a-zA-Z0-9_.]+\z/}
  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :name, format: {with: /\A[a-zA-Z\s]+\z/}, length: {minimum: 2, maximum: 30}

  before_validation :normalize_username, :normalize_email
  before_create :normalize_name
  after_create :create_default_membership 
  after_commit :send_welcome_email #will send while updating also, fix it


  def normalize_username
    self.username = username.downcase.strip if username.present?
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_name
    self.name = name.squish.titleize if name.present?
  end

  def create_default_membership
    if self.actable_type == "Member"
      tier = MembershipTier.find_by(name: 'Free', country: self.country)
      if tier.nil?
        tier = MembershipTier.find_by(name: 'Free', country: :unknown)
      end
      create_membership(membership_tier: tier, status: :active)
    end
  end

  def send_welcome_email
    puts "Welcome mail sent to #{email}"
  end

end
