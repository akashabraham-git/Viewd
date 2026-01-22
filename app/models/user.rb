class User < ApplicationRecord
  acts_as_paranoid

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :actable, polymorphic: true, dependent: :destroy
           
  has_many :access_tokens, 
           class_name: 'Doorkeeper::AccessToken', 
           foreign_key: :resource_owner_id, 
           dependent: :delete_all

  delegate :bio, :country, to: :actable, allow_nil: true
  accepts_nested_attributes_for :actable

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }, format: { with: /\A[a-zA-Z0-9_.]+\z/ }
  validates :email, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :normalize_username, :normalize_email
  before_create :normalize_name

  scope :member, -> { where('actable_type ILIKE ?', "member") }
  scope :moderator, -> { where('actable_type ILIKE ?', "moderator") }

  def actable_attributes=(attributes)
    if self.actable_type.nil? || self.actable_type == 'Member'
      self.actable ||= Member.new
      self.actable.assign_attributes(attributes)
    end
  end

  def build_member_identity
    self.actable ||= Member.new if self.actable_type.nil? || self.actable_type == 'Member'
  end

  # --- Devise / Authentication Overrides ---

  def self.authenticate(email, password)
    user = User.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end

  def self.find_for_authentication(tainted_conditions)
    with_deleted.find_first_by_auth_conditions(tainted_conditions)
  end

  def active_for_authentication?
    return super unless deleted?

    if deleted_at > 1.year.ago
      recover 
      true
    else
      false 
    end
  end

  def inactive_message
    deleted? ? :deleted_account_expired : super
  end

  def self.send_reset_password_instructions(attributes={})
    email = attributes[:email]
    recoverable = with_deleted.find_by(email: email)

    if recoverable
      if recoverable.deleted? && recoverable.deleted_at < 1.year.ago
        recoverable.errors.add(:base, :deleted_account_expired)
        return recoverable
      end
      raw, enc = Devise.token_generator.generate(self, :reset_password_token)
      User.unscoped.where(id: recoverable.id).update_all(
        reset_password_token: enc,
        reset_password_sent_at: Time.now.utc
      )
      
      recoverable.send(:send_devise_notification, :reset_password_instructions, raw, {})
    else
      recoverable = new(attributes)
      recoverable.errors.add(:email, :not_found)
    end
    
    recoverable
  end

  def self.with_reset_password_token(token)
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token)
    unscoped.find_by(reset_password_token: reset_password_token)
  end

  def reset_password(new_password, new_password_confirmation)
    recover if deleted? && deleted_at > 1.year.ago
    super 
  end

  def self.reset_password_by_token(attributes = {})
    token = attributes[:reset_password_token]
    recoverable = with_reset_password_token(token)

    if recoverable&.persisted?
      if recoverable.reset_password_period_valid?
        recoverable.recover if recoverable.deleted?
        recoverable.reset_password(attributes[:password], attributes[:password_confirmation])
      else
        recoverable.errors.add(:reset_password_token, :expired)
      end
      return recoverable
    end
    new
  end


  def destroy
    actable_type == 'Moderator' ? destroy_fully! : update_column(:deleted_at, Time.current)
  end

  def recover
    if deleted_at.present? && deleted_at > 1.year.ago
      self.class.unscoped { super(recursive: true) }
      true
    else
      false  
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "username", "name", "email", "actable_type", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["actable"]
  end

  private

  def normalize_username
    self.username = username.downcase.strip if username.present?
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_name
    self.name = name.squish.titleize if name.present?
  end
end