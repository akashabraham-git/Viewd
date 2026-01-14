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

end