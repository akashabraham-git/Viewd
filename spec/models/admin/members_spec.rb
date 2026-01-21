require 'rails_helper'

RSpec.describe "Admin::Members", type: :request do
  let!(:admin_user) { create(:admin_user) }
  let!(:member) { create(:member) }
  let!(:user) { member.user }

  before do
    sign_in admin_user
  end

  describe "Index page" do
    it "renders the member list with user details" do
      get admin_members_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.username)
      expect(response.body).to include(user.email)
    end

    it "filters members by username" do
      get admin_members_path, params: { q: { user_username_cont: user.username } }
      expect(response.body).to include(user.username)
      
      get admin_members_path, params: { q: { user_username_cont: "nonexistent" } }
      expect(response.body).not_to include(user.username)
    end
  end

  describe "Show page" do
    it "renders member attributes and panels" do
      get admin_member_path(member)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Membership Details")
      expect(response.body).to include("Connection Stats")
    end

    it "contains links to connections" do
      get admin_member_path(member)
      expect(response.body).to include("View Following List")
      expect(response.body).to include("View Followers List")
    end
  end

  describe "Controller Logic (Update)" do
    context "when password params are blank" do
      let(:update_params) do
        {
          member: {
            bio: "Updated bio",
            user_attributes: {
              id: user.id,
              username: "new_username",
              password: "",
              password_confirmation: ""
            }
          }
        }
      end

      it "updates the user without changing the password" do
        patch admin_member_path(member), params: update_params
        
        expect(response).to redirect_to(admin_member_path(member))
        user.reload
        expect(user.username).to eq("new_username")
        expect(user.encrypted_password).to be_present 
      end
    end

    context "when providing a new password" do
      it "updates the password successfully" do
        patch admin_member_path(member), params: {
          member: {
            user_attributes: {
              id: user.id,
              password: "newpassword123",
              password_confirmation: "newpassword123"
            }
          }
        }
        
        expect(flash[:notice]).to include("Member was successfully updated")
      end
    end
  end

  describe "Form" do
    it "renders the semantic form for user and member" do
      get edit_admin_member_path(member)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("User Account")
      expect(response.body).to include("Member Profile")
    end
  end
end