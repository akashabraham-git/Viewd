require 'rails_helper'

RSpec.describe "Api::V1::Reviews", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }
  let!(:review) { create(:review, movie: movie, member: member_record) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns reviews for a movie ordered by likes" do
      create_list(:review, 3, movie: movie)
      get "/api/v1/movies/#{movie.id}/reviews"
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for missing movie" do
      get "/api/v1/movies/0/reviews"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /show" do
    it "renders the review and fetches the associated rating" do
      get "/api/v1/reviews/#{review.id}"
      
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:valid_params) { { review: { content: "Great movie!" } } }

    context "as a member" do
      before { sign_in_as(user) }

      it "creates a review" do
        expect {
          post "/api/v1/movies/#{movie.id}/reviews", params: valid_params
        }.to change(Review, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "returns 422 on validation failure" do
        post "/api/v1/movies/#{movie.id}/reviews", params: { review: { content: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "as a moderator" do
      it "denies review creation" do
        sign_in_as(create(:moderator).user)
        post "/api/v1/movies/#{movie.id}/reviews", params: valid_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /update" do
    before { sign_in_as(user) }

    it "allows owner to update" do
      patch "/api/v1/reviews/#{review.id}", params: { review: { content: "Updated content" } }
      expect(response).to have_http_status(:ok)
      expect(review.reload.content).to eq("Updated content")
    end

    it "denies non-owner" do
      sign_in_as(create(:member).user)
      patch "/api/v1/reviews/#{review.id}", params: { review: { content: "Hack" } }
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 and hits the failure" do
        patch "/api/v1/reviews/#{review.id}", params: { review: { content: "" } }
        
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json).to have_key("error") 
      end
  end

  describe "DELETE /destroy" do
    before { sign_in_as(user) }

    it "allows owner to delete" do
      expect {
        delete "/api/v1/reviews/#{review.id}"
      }.to change(Review, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it "returns 422 if destroy fails" do
      allow_any_instance_of(Review).to receive(:destroy).and_return(false)
      delete "/api/v1/reviews/#{review.id}"
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end