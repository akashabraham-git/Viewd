require 'rails_helper'

RSpec.describe "Users", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:member_record) { create(:member) }
  let!(:other_member) { create(:member) }
  let(:user) { member_record.user }
  let(:other_user) { other_member.user }
  let!(:movie) { create(:movie) }

  describe "GET /show" do
    it "renders profile with stats for a member" do
      member = user.actable
      create(:library_entry, member: member, movie: movie, watched_date: Date.today)
      
      get user_path(user)
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("1") 
    end

    it "redirects for invalid user" do
      get "/users/0"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Invalid user")
    end
  end

  describe "GET /edit" do
    it "allows owner to edit" do
      sign_in user
      get edit_user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "denies non-owner" do
      sign_in user
      get edit_user_path(other_user)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Unauthorized")
    end
  end

  describe "PATCH /update" do
    before { sign_in user }

    it "updates with valid params" do
      patch user_path(user), params: { user: { name: "New Name" } }
      expect(user.reload.name).to eq("New Name")
      expect(response).to redirect_to(user_path(user))
    end

    it "renders edit on failure" do
      patch user_path(user), params: { user: { username: "" } } 
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "prevents updating other users" do
      patch user_path(other_user), params: { user: { name: "Hacker" } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /destroy" do
    before { sign_in user }

    it "deletes the account" do
      expect {
        delete user_path(user)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end

    it "when destroy fails" do
      allow_any_instance_of(User).to receive(:destroy).and_return(false)
      
      errors_stub = double('errors', full_messages: ["Cannot delete account"])
      allow_any_instance_of(User).to receive(:errors).and_return(errors_stub)

      delete user_path(user)
      
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to eq("Cannot delete account")
    end
  end
end