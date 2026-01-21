require 'rails_helper'

RSpec.describe "Movies", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:member_record) { create(:member) }
  let!(:moderator_record) { create(:moderator) }
  let(:member_user) { member_record.user }
  let(:moderator_user) { moderator_record.user }
  let!(:movie) { create(:movie, title: "Inception") }

  describe "GET /index" do
    it "renders the index template" do
      get movies_path
      expect(response).to have_http_status(:ok)
    end

    context "with search" do
      it "searches movies" do
        get movies_path, params: { query: "Movie", type: "movies" }
        expect(response).to have_http_status(:ok)
      end

      it "searches users" do
        get movies_path, params: { query: "user", type: "users" }
        expect(response).to have_http_status(:ok)
      end

      it "searches cast" do
        get movies_path, params: { query: "actor", type: "cast" }
        expect(response).to have_http_status(:ok)
      end

      it "searches genres" do
        get movies_path, params: { query: "action", type: "genres" }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /show" do
    before do
      create(:credit, movie: movie, job: 'Actor')
      create(:credit, movie: movie, job: 'Director')
      create(:library_entry, movie: movie, member: member_record, watched_date: Date.today)
      create(:review, movie: movie, member: member_record)
      create(:like, likeable: movie, member: member_record)
      
      sign_in member_user
    end

    it "renders show template for existing movie", :aggregate_failures do
      get movie_path(movie)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(movie.title)
    end

    it "redirects for non-existent movie" do
      get movie_path(id: 0)
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Error: Movie not found.")
    end
  end

  describe "GET /new" do
    before { sign_in moderator_user }

    it "assigns a new movie and renders the new template" do
      get new_movie_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("New Movie") 
    end
  end

  describe "POST /create" do
    let(:valid_params) do 
      { 
        movie: { 
          title: "New", 
          synopsis: "Detailed synopsis here that is long enough", 
          release_date: Date.today,
          poster_url: "https://example.com/new_poster.jpg" 
        } 
      } 
    end

    before { sign_in moderator_user }

    it "creates a movie" do
      expect {
        post movies_path, params: valid_params
      }.to change(Movie, :count).by(1)
      expect(response).to redirect_to(Movie.last)
    end

    it "renders new on error" do
      post movies_path, params: { movie: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /update" do
    before { sign_in moderator_user }

    it "updates the movie" do
      patch movie_path(movie), params: { movie: { title: "Updated" } }
      expect(movie.reload.title).to eq("Updated")
      expect(response).to redirect_to(movie)
    end

    it "renders edit on failure" do
      patch movie_path(movie), params: { movie: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /destroy" do
    before { sign_in moderator_user }

    it "removes the movie" do
      expect {
        delete movie_path(movie)
      }.to change(Movie, :count).by(-1)
      expect(response).to redirect_to(movies_path)
    end
  end
end