require 'rails_helper'

RSpec.describe "Api::V1::Members", type: :request do
  let!(:member_record) { create(:member, bio: "Original Bio") }
  let(:user) { member_record.user }
  let(:other_member) { create(:member) }
  let!(:movie) { create(:movie) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /show and specialized actions" do
    it "shows member profile" do
      get "/api/v1/members/#{member_record.id}"
      expect(response).to have_http_status(:ok)
    end

    it "returns watchlist" do
      create(:library_entry, member: member_record, movie: movie, in_watchlist: true)
      get "/api/v1/members/#{member_record.id}/watchlist"
      expect(response).to have_http_status(:ok)
    end

    it "returns liked movies" do
      create(:like, member: member_record, likeable: movie)
      get "/api/v1/members/#{member_record.id}/likes"
      expect(response).to have_http_status(:ok)
    end

    it "returns library (watched movies)" do
      create(:library_entry, member: member_record, movie: movie, watched_date: Date.today)
      get "/api/v1/members/#{member_record.id}/library"
      expect(response).to have_http_status(:ok)
    end

    it "returns reviews" do
      create(:review, member: member_record, movie: movie)
      get "/api/v1/members/#{member_record.id}/reviews"
      expect(response).to have_http_status(:ok)
    end
    
    it "returns 404 for missing member" do
      get "/api/v1/members/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        member: {
          bio: "New Member",
          user_attributes: {
            name: "John Doe",
            email: "john@example.com",
            username: "johndoe",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }
    end

    it "creates a new member" do
      expect {
        post "/api/v1/members", params: valid_params
      }.to change(Member, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns 422 on failure" do
      post "/api/v1/members", params: { member: { bio: "" } } 
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /update" do
    before { sign_in_as(user) }

    it "updates the member profile" do
      patch "/api/v1/members/#{member_record.id}", params: { member: { bio: "Updated Bio" } }
      expect(response).to have_http_status(:ok)
      expect(member_record.reload.bio).to eq("Updated Bio")
    end

    it "denies non-member types (e.g. Moderator)" do
      mod_user = create(:moderator).user
      sign_in_as(mod_user)
      patch "/api/v1/members/#{member_record.id}", params: { member: { bio: "Hack" } }
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 on failure" do
      patch "/api/v1/members/#{member_record.id}", params: { member: { bio: "" } } 
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end