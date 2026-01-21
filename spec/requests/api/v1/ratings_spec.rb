require 'rails_helper'

RSpec.describe "Api::V1::Ratings", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  before { sign_in_as(user) }

  describe "POST /create" do
    it "creates a rating with valid score" do
      expect {
        post "/api/v1/movies/#{movie.id}/rating", params: { rating: 5 }
      }.to change(Rating, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns 422 for invalid score (<= 0)" do
      post "/api/v1/movies/#{movie.id}/rating", params: { rating: 0 }
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid rating score")
    end

    it "returns 422 on database validation failure" do
      allow_any_instance_of(Rating).to receive(:save).and_return(false)
      errors_stub = double('errors', full_messages: ["Payment failed"])
      allow_any_instance_of(Rating).to receive(:errors).and_return(errors_stub)
      
      post "/api/v1/movies/#{movie.id}/rating", params: { rating: 5 }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /update" do
    let!(:rating) { create(:rating, member: member_record, movie: movie, rating: 3) }

    it "updates an existing rating" do
      patch "/api/v1/movies/#{movie.id}/rating", params: { rating: 4 }
      expect(response).to have_http_status(:ok)
      expect(rating.reload.rating).to eq(4)
    end

    it "returns 404 if rating record doesn't exist" do
      other_movie = create(:movie)
      patch "/api/v1/movies/#{other_movie.id}/rating", params: { rating: 5 }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 if update fails" do
      allow_any_instance_of(Rating).to receive(:update).and_return(false)
      patch "/api/v1/movies/#{movie.id}/rating", params: { rating: 5 }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /destroy" do
    it "removes an existing rating" do
      create(:rating, member: member_record, movie: movie)
      expect {
        delete "/api/v1/movies/#{movie.id}/rating"
      }.to change(Rating, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it "handles case where no rating exists to remove" do
      delete "/api/v1/movies/#{movie.id}/rating"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("No rating found to remove")
    end
  end

  describe "Error Handling" do
    it "returns 404 for missing movie" do
      post "/api/v1/movies/0/rating", params: { rating: 5 }
      expect(response).to have_http_status(:not_found)
    end
  end
end