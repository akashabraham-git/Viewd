require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { create(:admin_user) }
  let!(:member_user) { create(:user, :as_member, name: "John Member") }
  let!(:moderator_user) { create(:user, :as_moderator, name: "Jane Moderator") }

  before do
    sign_in admin
  end

  describe "Index Page" do
    it "renders the table with scopes" do
      get admin_users_path
      expect(response).to have_http_status(:success)
      
      get admin_users_path(scope: 'all')
      expect(response.body).to include("Actable Type")
      
      get admin_users_path(scope: 'member')
      expect(response.body).to include("John Member")
      
      get admin_users_path(scope: 'moderator')
      expect(response.body).to include("Jane Moderator")
    end

    it "exercises filters" do
      get admin_users_path(q: { email_contains: member_user.email })
      expect(response).to have_http_status(:success)
    end
  end

  describe "Show Page" do
    it "renders Member details including bio and country" do
      get admin_user_path(member_user)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Member")
      expect(response.body).to include(member_user.actable.bio)
    end

    it "renders Moderator details (else branch)" do
      get admin_user_path(moderator_user)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Moderator")
      expect(response.body).to include(moderator_user.actable.id.to_s)
    end
  end

  describe "Form Rendering" do
    it "renders the edit form" do
      get edit_admin_user_path(member_user)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Account Details")
    end
  end

  describe "Custom Controller Update" do
    it "updates without password (triggers params delete logic)" do
      patch admin_user_path(member_user), params: {
        user: {
          name: "Updated Name",
          password: "",
          password_confirmation: ""
        }
      }
      expect(response).to redirect_to(admin_user_path(member_user))
      expect(member_user.reload.name).to eq("Updated Name")
    end

    it "updates with password" do
      patch admin_user_path(member_user), params: {
        user: {
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
      expect(response).to redirect_to(admin_user_path(member_user))
    end
  end

  describe "Restricted Actions" do
    it "does not have a new page" do
      get "/admin/users/new"
      expect(response).to have_http_status(:not_found)
    end
  end
end