require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let!(:member_record) { create(:member) }
  let!(:other_member) { create(:member) }
  let(:user) { member_record.user }
  let(:other_user) { other_member.user }
  let!(:movie) { create(:movie) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /show" do
    context "when user is a Member with activity" do
      before do
        create(:library_entry, member: member_record, movie: movie, watched_date: Date.today, in_watchlist: true)
        create(:like, member: member_record, likeable: movie)
        create(:review, member: member_record, movie: movie)
        get api_v1_user_path(user), as: :json
      end

      it "returns OK with stats", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json).to have_key("statistics")
        expect(json["statistics"]["films_count"]).to eq(1)
        expect(json["statistics"]["this_year_count"]).to eq(1)

        expect(json["favorite_movies"]).not_to be_empty
        expect(json["watchlist"]).not_to be_empty
        expect(json["recent_activity"]).not_to be_empty
        expect(json["top_reviews"]).not_to be_empty
      end
    end

    context "when user is a moderator" do
      let!(:moderator) { create(:moderator) }
      let(:mod_user) { moderator.user }

      it "returns OK with no stats" do
        get api_v1_user_path(mod_user), as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["statistics"]).to be_nil
      end
    end

    context "when user does not exist" do
      it "returns 404" do
        get "/api/v1/users/0", as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /update" do
    let(:valid_params) { { user: { username: "updated_username" } } }

    context "when authorized" do
      before do
        sign_in_as(user)
        patch api_v1_user_path(user), params: valid_params, as: :json
      end

      it "updates successfully" do
        expect(response).to have_http_status(:ok)
        expect(user.reload.username).to eq("updated_username")
      end
    end

    context "when unauthorized" do
      it "returns 403" do
        sign_in_as(other_user)
        patch api_v1_user_path(user), params: valid_params, as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when update fails" do
      it "returns 422" do
        sign_in_as(user)
        allow_any_instance_of(User).to receive(:update).and_return(false)
        errors_stub = double('errors', full_messages: ["Update error"])
        allow_any_instance_of(User).to receive(:errors).and_return(errors_stub)
        patch api_v1_user_path(user), params: valid_params, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when authorized" do
      it "deletes the user" do
        sign_in_as(user)
        expect {
          delete api_v1_user_path(user), as: :json
        }.to change(User, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when deletion fails" do
      it "returns 422" do
        sign_in_as(user)
        allow_any_instance_of(User).to receive(:destroy).and_return(false)
        errors_stub = double('errors', full_messages: ["Delete error"])
        allow_any_instance_of(User).to receive(:errors).and_return(errors_stub)
        delete api_v1_user_path(user), as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end