require 'rails_helper'

RSpec.describe "Api::V1::LibraryEntries", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  before { sign_in_as(user) }

  describe "PATCH /toggle_watched" do
    context "when adding to watched" do
      it "sets watched_date and removes from watchlist" do
        patch toggle_watched_api_v1_movie_path(movie)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["watched"]).to be true
        expect(LibraryEntry.last.watched_date).not_to be_nil
      end
    end

    context "when removing from watched" do
      let!(:entry) { create(:library_entry, member: member_record, movie: movie, watched_date: Date.today) }

      it "removes watched_date if no activity exists" do
        patch toggle_watched_api_v1_movie_path(movie)
        expect(response).to have_http_status(:ok)
        expect(LibraryEntry.exists?(id: entry.id)).to be false
      end

      it "returns 422 if a rating exists" do
        create(:rating, member: member_record, movie: movie, rating: 5)
        patch toggle_watched_api_v1_movie_path(movie)
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("activity")
      end

      it "returns 422 if a review exists" do
        create(:review, member: member_record, movie: movie)
        patch toggle_watched_api_v1_movie_path(movie)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /toggle_watchlist" do
    it "toggles in_watchlist status" do
      patch toggle_watchlist_api_v1_movie_path(movie)
      expect(JSON.parse(response.body)["in_watchlist"]).to be true
      
      patch toggle_watchlist_api_v1_movie_path(movie)
      expect(JSON.parse(response.body)["in_watchlist"]).to be false
    end
  end

  describe "Error Handling" do
    it "returns 404 for missing movie" do
      patch "/api/v1/movies/0/toggle_watched"
      expect(response).to have_http_status(:not_found)
    end
  end
end