require 'rails_helper'

RSpec.describe "Api::V1::Likes", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }
  let!(:review) { create(:review, movie: movie) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  before { sign_in_as(user) }

  describe "Review Likes" do
    context "POST /api/v1/reviews/:id/like" do
      it "creates a review like successfully" do
        post "/api/v1/reviews/#{review.id}/like"
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Review liked")
        expect(json["liked"]).to be true
        expect(review.likes.count).to eq(1)
      end

      it "returns 404 if review does not exist" do
        post "/api/v1/reviews/0/like"
        
        expect(response).to have_http_status(:not_found)
      end
    end

    context "DELETE /api/v1/reviews/:id/like" do
      it "destroys a review like successfully" do
        review.likes.create!(member: member_record)
        
        delete "/api/v1/reviews/#{review.id}/like"
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Review unliked")
        expect(json["liked"]).to be false
        expect(review.likes.count).to eq(0)
      end
    end
  end

  describe "Movie Likes" do
    context "POST /api/v1/movies/:id/like" do
      it "likes a movie" do
        post "/api/v1/movies/#{movie.id}/like"
        expect(response).to have_http_status(:ok)
        expect(movie.likes.count).to eq(1)
      end
    end

    context "DELETE /api/v1/movies/:id/like" do
      it "deletes a movie like" do
        delete "/api/v1/movies/#{movie.id}/like"
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Movie unliked")
        expect(json["liked"]).to be false
        expect(movie.likes.count).to eq(0)
      end
    end
  end
end