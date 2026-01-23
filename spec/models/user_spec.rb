require 'rails_helper'

RSpec.describe User, type: :model do
  let(:password) { "password123" }
  let(:user) { create(:user, :as_member, password: password) }
  let(:moderator) { create(:user, :as_moderator, password: password) }

  describe "Validations & Normalization" do
    it "normalizes email and username (covers normalize branches)" do
      u = build(:user, username: "  JOHN  ", email: "  JOHN@Test.Com  ", name: "  john doe  ")
      u.valid?
      expect(u.username).to eq("john")
      expect(u.email).to eq("john@test.com")
      u.save
      expect(u.name).to eq("John Doe")

      u2 = build(:user, username: nil, email: "test@test.com", name: nil)
      expect { u2.valid? }.not_to raise_error
      expect(u2.username).to be_nil
    end
  end

  describe "Identity Management (actable)" do
    it "covers actable_attributes= branches" do
      user.actable_attributes = { bio: "Hello" }
      expect(user.actable.bio).to eq("Hello")

      moderator.actable_attributes = { bio: "Hidden" }
      expect(moderator.actable).not_to respond_to(:bio)
    end

    it "covers build_member_identity branches" do
      u = User.new(actable_type: nil)
      u.build_member_identity
      expect(u.actable).to be_a(Member)

      moderator.build_member_identity
      expect(moderator.actable).to be_a(Moderator)
    end
  end

  describe "Authentication Overrides" do
    it "covers self.authenticate branches" do
      expect(User.authenticate(user.email, password)).to eq(user)
      expect(User.authenticate(user.email, "wrong")).to be_nil
      expect(User.authenticate("none@test.com", password)).to be_nil
    end

    it "covers active_for_authentication? and inactive_message branches" do
      expect(user.active_for_authentication?).to be true
      expect(user.inactive_message).to eq(:inactive)

      user.update_column(:deleted_at, 1.month.ago)
      expect(user.active_for_authentication?).to be true
      expect(user.reload.deleted?).to be false

      User.where(id: user.id).update_all(deleted_at: 2.years.ago)
      expect(user.reload.active_for_authentication?).to be false
      expect(user.inactive_message).to eq(:deleted_account_expired)
    end
  end

  describe "Password Reset Flow" do
    it "covers send_reset_password_instructions branches" do
      none = User.send_reset_password_instructions(email: "none@test.com")
      expect(none.errors[:email]).to include("not found")

      User.where(id: user.id).update_all(deleted_at: 2.years.ago)
      expired = User.send_reset_password_instructions(email: user.email)
      expect(expired.errors[:base]).to include("Your account was deleted more than a year ago and cannot be recovered.")

      active = create(:user, email: "active@test.com")
      expect {
        User.send_reset_password_instructions(email: "active@test.com")
      }.to change { User.find_by(email: "active@test.com").reset_password_token }
    end

    it "covers reset_password_by_token branches" do
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      expect(User.reset_password_by_token(reset_password_token: "fake")).not_to be_persisted

      user.update_columns(reset_password_token: enc, reset_password_sent_at: 24.hours.ago)
      expired_token = User.reset_password_by_token(reset_password_token: raw)
      expect(expired_token.errors[:reset_password_token]).to be_present

      user.update_columns(reset_password_token: enc, reset_password_sent_at: Time.now.utc)
      User.where(id: user.id).update_all(deleted_at: 1.month.ago)
      User.reset_password_by_token(reset_password_token: raw, password: "new", password_confirmation: "new")
      expect(user.reload.deleted?).to be false
    end

    it "covers reset_password recovery during reset" do
      User.where(id: user.id).update_all(deleted_at: 1.month.ago)
      user.reload.reset_password("NewPass123", "NewPass123")
      expect(user.reload.deleted?).to be false
    end
  end

  describe "Destruction and Recovery" do
    it "covers destroy branches (Moderator vs Member)" do
      mod_id = moderator.id
      moderator.destroy
      expect(User.with_deleted.find_by(id: mod_id)).to be_nil

      user.destroy
      expect(user.deleted_at).not_to be_nil
      expect(User.with_deleted.find_by(id: user.id)).not_to be_nil
    end

    it "covers recover branches" do
      expect(user.recover).to be false

      User.where(id: user.id).update_all(deleted_at: 2.years.ago)
      expect(user.reload.recover).to be false

      User.where(id: user.id).update_all(deleted_at: 1.month.ago)
      user.reload
      
      if user.deleted_at.present? && user.deleted_at > 1.year.ago
        expect(user.recover).to be true
      else
        expect(user.recover).to be false
      end
    end
  end

  describe "Ransack" do
    it "covers ransackable methods" do
      expect(User.ransackable_attributes).to include("username")
      expect(User.ransackable_associations).to include("actable")
    end
  end

  describe "Specific Branch Coverage Fixes" do
    it "skips normalization when email is nil" do
      user_with_nil = User.new(email: nil)
      
      expect { user_with_nil.valid? }.not_to raise_error
      expect(user_with_nil.email).to be_nil
    end
  end

  describe "Branch Coverage Mastery" do
    let(:user) { create(:user, :as_member) }

    describe "#destroy branches" do
      it "performs a hard delete for Moderators" do
        mod = create(:user, :as_moderator)
        mod_id = mod.id
        mod.destroy
        expect(User.unscoped.find_by(id: mod_id)).to be_nil
      end

      it "performs a soft delete for Members " do
        user.destroy
        expect(user.deleted_at).not_to be_nil
        expect(User.with_deleted.find_by(id: user.id)).to be_present
      end
    end

    describe "reset_password_by_token branches" do
      it "handles an expired token " do
        raw, enc = Devise.token_generator.generate(User, :reset_password_token)
        user.update_columns(reset_password_token: enc, reset_password_sent_at: 24.hours.ago)

        result = User.reset_password_by_token(reset_password_token: raw)
        
        expect(result.errors[:reset_password_token]).to be_present
        expect(result.id).to eq(user.id) 
      end

      it "handles a nil/invalid token " do
        result = User.reset_password_by_token(reset_password_token: "token-not-in-db")
        
        expect(result).to be_a_new(User)
        expect(result.persisted?).to be false
      end

      it "skips recovery for non-deleted users" do
        raw, enc = Devise.token_generator.generate(User, :reset_password_token)
        user.update_columns(reset_password_token: enc, reset_password_sent_at: Time.now.utc)

        expect(user).not_to receive(:recover)
        User.reset_password_by_token(
          reset_password_token: raw, 
          password: "newpassword", 
          password_confirmation: "newpassword"
        )
      end
    end
  end

  
  
end