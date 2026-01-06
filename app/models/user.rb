class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :actable, polymorphic: true
  delegate :bio, :country, to: :actable, allow_nil: true
  accepts_nested_attributes_for :actable

  validates :username, presence: true, uniqueness: true, length: {minimum: 3, maximum: 20}, format: {with: /\A[a-zA-Z0-9_.]+\z/}
  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  #validates :name, format: {with: /\A[a-zA-Z\s]+\z/}, length: {minimum: 2, maximum: 30}

  before_validation :normalize_username, :normalize_email
  before_create :normalize_name
  after_commit :send_welcome_email, on: :create

  scope :member, -> { where('actable_type ILIKE ?', "member") }
  scope :moderator, -> { where('actable_type ILIKE ?', "moderator") }

  def normalize_username
    self.username = username.downcase.strip if username.present?
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_name
    self.name = name.squish.titleize if name.present?
  end

  def send_welcome_email
    puts "Welcome mail sent to #{email}"
  end

  def actable_attributes=(attributes)
    if self.actable_type.nil? || self.actable_type == 'Member'
      self.actable ||= Member.new
      self.actable.assign_attributes(attributes)
    end
  end

  def build_member_identity
    self.actable ||= Member.new if self.actable_type.nil? || self.actable_type == 'Member'
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "username", "name", "email", "actable_type", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["actable"]
  end

end
