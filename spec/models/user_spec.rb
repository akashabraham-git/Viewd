require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with a unique username and email" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is invalid if username is too short" do
      user = build(:user, username: "ab")
      expect(user).not_to be_valid
    end
  end

  it { should belong_to(:actable) }

  describe "normalization" do
    it "downcases and strips the email before validation" do
      user = build(:user, email: "  UPPER@example.com  ")
      user.valid? 
      expect(user.email).to eq("upper@example.com")
    end

    it "titleizes the name before creating" do
      user = create(:user, name: "akash abraham")
      expect(user.name).to eq("Akash Abraham")
    end
  end

  describe "polymorphic identity management" do
    it "updates the associated member through the user" do
      user = create(:user, :as_member)
      user.actable_attributes = { bio: "Updated bio via factory", country: :india }
      user.save
      
      expect(user.actable.bio).to eq("Updated bio via factory")
      expect(user.actable.country).to eq("india")
    end

    it "initializes a member profile if one is missing" do
      user = build(:user, actable: nil)
      
      user.build_member_identity
      expect(user.actable).to be_a(Member)
    end
  end

  describe "authentication" do
    let!(:auth_user) do 
      create(:user, 
             email: "login@test.com", 
             password: "securepassword123", 
             password_confirmation: "securepassword123") 
    end

    it "returns the user when credentials are valid" do
      result = User.authenticate("login@test.com", "securepassword123")
      expect(result).to eq(auth_user)
    end
  end

  describe "admin search configuration" do
    it "defines ransackable attributes" do
      expect(User.ransackable_attributes).to match_array(["id", "username", "name", "email", "actable_type", "created_at", "updated_at"])
    end

    it "defines ransackable associations" do
      expect(User.ransackable_associations).to match_array(["actable"])
    end
  end

end