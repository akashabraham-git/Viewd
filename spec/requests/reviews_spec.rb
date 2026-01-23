require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }
  let!(:review) { create(:review, movie: movie, member: member_record, content: "Great movie!") }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(user).to receive(:actable).and_return(member_record)
  end

  describe "GET /index" do
    it "renders reviews index" do
      get movie_reviews_path(movie)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "renders show " do
      get review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => movie_path(movie) }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "creates review and triggers mark_as_watched callback" do
      expect {
        post movie_reviews_path(movie), params: { review: { content: "I loved this film!" } }
      }.to change(Review, :count).by(1)
      
      entry = LibraryEntry.find_by(member: member_record, movie: movie)
      expect(entry.watched_date).to eq(Date.today)
      expect(response).to redirect_to(movie_path(movie))
    end

    it "redirects on failure" do
      post movie_reviews_path(movie), params: { review: { content: "a" } }
      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:alert]).to be_present
    end
  end

  describe "GET /edit" do
    it "renders edit and sets session return path" do
      get edit_review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => movie_path(movie) }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    it "updates review and redirects to session path" do
      get review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => movie_path(movie) }
      
      patch review_path(review, movie_id: movie.id), params: { review: { content: "Updated valid content" } }
      expect(review.reload.content).to eq("Updated valid content")
      expect(response).to redirect_to(movie_path(movie))
    end

    it "redirects back on update failure" do
      patch review_path(review, movie_id: movie.id), params: { review: { content: "" } }
      expect(response).to have_http_status(:found)
      expect(flash[:alert]).to be_present
    end
  end


  describe "DELETE /destroy" do
    context "when deleting from the review show page" do
      it "uses the session return path" do
        get review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => movie_url(movie) }

        review_url_string = review_url(review, movie_id: movie.id)

        delete review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => review_url_string }

        expect(response).to redirect_to(movie_path(movie))
        expect(flash[:notice]).to eq("Review deleted.")
      end
    end

    context "when deleting from the movie index/show" do
      it "redirects to the movie page " do
        delete review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => movie_url(movie) }
        
        expect(response).to redirect_to(movie_url(movie))
        expect(flash[:notice]).to eq("Review deleted.")
      end
    end

    context "when destroy fails" do
      it "redirects back with alert" do
        allow_any_instance_of(Review).to receive(:destroy_fully!).and_return(false)
        delete review_path(review, movie_id: movie.id), headers: { "HTTP_REFERER" => movie_url(movie) }
        
        expect(response).to redirect_to(movie_url(movie))
      end
    end
  end
end