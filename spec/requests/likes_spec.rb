require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }
  let!(:review) { create(:review, movie: movie, member: member_record) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(user).to receive(:actable).and_return(member_record)
    @headers = { "HTTP_REFERER" => movie_path(movie) }
  end

  describe "POST /movies/:id/toggle_movie_like" do
    context "when user is signed in" do
      it "creates a like if it doesn't exist" do
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.to change(Like, :count).by(1)
        expect(response).to redirect_to(movie_path(movie))
      end

      it "removes a like if it already exists" do
        movie.likes.create!(member: member_record)
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.to change(Like, :count).by(-1)
      end
    end

    context "when user is a guest" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "redirects with an alert" do
        post toggle_movie_like_movie_path(movie), headers: @headers
        expect(flash[:alert]).to eq("sign in for liking")
        expect(response).to redirect_to(movie_path(movie))
      end
    end
  end

  describe "POST /movies/:movie_id/reviews/:id/toggle_like" do
    let(:path) { toggle_like_movie_review_path(movie, review) }

    context "when user is signed in" do
      it "adds a like to the review" do
        expect {
          post path, headers: @headers
        }.to change(Like, :count).by(1)
        expect(response).to redirect_to(movie_path(movie))
      end

      it "removes a like from the review" do
        review.likes.create!(member: member_record)
        expect {
          post path, headers: @headers
        }.to change(Like, :count).by(-1)
        expect(response).to redirect_to(movie_path(movie))
      end
    end

    context "when user is not signed in" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "redirects back with alert" do
        post path, headers: @headers
        expect(flash[:alert]).to eq("sign in for liking")
        expect(response).to redirect_to(movie_path(movie))
      end
    end
  end

  describe "Error Handling" do
    it "redirects to movies index if movie id is invalid" do
      post "/movies/999999/toggle_movie_like"
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Error: Movie not found.")
    end
  end
end