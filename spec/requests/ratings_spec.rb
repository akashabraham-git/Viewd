require 'rails_helper'

RSpec.describe "Ratings", type: :request do
  let!(:user) { create(:user) }
  let!(:member_profile) { create(:member, user: user) }
  let!(:movie) { create(:movie) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(user).to receive(:actable).and_return(member_profile)
    
    @headers = { "HTTP_REFERER" => movie_path(movie) }
  end

  describe "POST /movies/:id/toggle_rating" do
    context "when no rating exists" do
      it "creates a new rating and marks as watched" do
        expect {
          post toggle_rating_movie_path(movie), params: { rating: 5 }, headers: @headers
        }.to change(Rating, :count).by(1)

        expect(Rating.last.rating).to eq(5)
        expect(response).to redirect_to(movie_path(movie))
      end
    end

    context "when a rating already exists" do
      let!(:existing_rating) { create(:rating, member: member_profile, movie: movie, rating: 3) }

      it "updates the rating if the score is different" do
        post toggle_rating_movie_path(movie), params: { rating: 5 }, headers: @headers
        expect(existing_rating.reload.rating).to eq(5)
      end

      it "destroys the rating if the score is the same" do
        expect {
          post toggle_rating_movie_path(movie), params: { rating: 3 }, headers: @headers
        }.to change(Rating, :count).by(-1)
      end

      it "destroys the rating if the score provided is 0" do
        expect {
          post toggle_rating_movie_path(movie), params: { rating: 0 }, headers: @headers
        }.to change(Rating, :count).by(-1)
      end
    end

    it "sets the current_user_instance on the record" do
      allow_any_instance_of(Rating).to receive(:update).and_call_original
      
      expect_any_instance_of(Rating).to receive(:current_user_instance=).with(user)
      
      post toggle_rating_movie_path(movie), params: { rating: 4 }, headers: @headers
    end
  end
end