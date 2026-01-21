require 'rails_helper'

RSpec.describe "DeviseHooks", type: :request do
  let!(:user) { create(:user, password: "password123") }

  it "covers application controller devise logic" do
    post user_registration_path, params: { 
      user: { 
        email: "coverage_test@example.com", 
        password: "password123", 
        password_confirmation: "password123",
        username: "coverage_bot",
        actable_attributes: { bio: "Testing bio" }
      } 
    }

    post user_session_path, params: { 
      user: { 
        email: user.email, 
        password: "password123" 
      } 
    }
    expect(response).to redirect_to(root_path)
  end
end