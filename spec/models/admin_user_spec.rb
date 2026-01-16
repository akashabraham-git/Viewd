require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  describe "admin search configuration" do
    it "defines ransackable attributes for ActiveAdmin" do
      expect(AdminUser.ransackable_attributes).to match_array(["email", "created_at", "updated_at"])
    end
  end
end