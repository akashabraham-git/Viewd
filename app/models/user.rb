class User < ApplicationRecord
  has_many :incoming_connections, class_name: "Connection", foreign_key: "following_id", dependent: :destroy
  has_many :followers, through: :incoming_connections, source: :follower
  has_many :outgoing_connections, class_name: "Connection", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :outgoing_connections, source: :following
  has_many :library_entries, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one :membership, dependent: :destroy
  has_one :membership_tier, through: :membership
  has_many :lists, dependent: :destroy
  has_many :list_items, through: :lists, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :favorites, -> { order(position: :asc) }, dependent: :destroy
  has_many :favorite_movies, through: :favorites, source: :movie

  validates :username, presence: true, uniqueness: true, length: {minimum: 3, maximum: 20}, format: {with: /\A[a-zA-Z0-9_.]+\z/}
  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :name, format: {with: /\A[a-zA-Z\s]+\z/}, length: {minimum: 2, maximum: 30}

  before_validation :normalize_username, :normalize_email
  before_create :normalize_name
  after_create :create_default_membership
  after_commit :send_welcome_email

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
    tier = MembershipTier.find_by(name: 'Free', country: self.country)
    if tier.nil?
      tier = MembershipTier.find_by(name: 'Free', country: :usa)
    end
    create_membership!(membership_tier: tier, status: :active)
  end

  def send_welcome_email
    puts "Welcome mail sent to #{email}"
  end

  def following?(other_user)
    following.include?(other_user)
  end

end
