require 'rails_helper'

RSpec.describe "Admin::Movies", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { create(:admin_user) }
  let!(:movie) { create(:movie, status: :released, poster_url: 'http://example.com/p.jpg', runtime: 120) }
  let!(:genre) { create(:genre) }
  let!(:cast_member) { create(:cast) }

  before do
    sign_in admin
  end

  describe "Index Page" do
    it "renders table, custom columns, and rating logic" do
      create(:rating, movie: movie, rating: 4)
      get admin_movies_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(movie.title)
      expect(response.body).to include("4.0 / 5")
    end

    it "exercises all defined scopes" do
      get admin_movies_path(scope: 'all')
      get admin_movies_path(scope: 'released')
      get admin_movies_path(scope: 'recent')
      expect(response).to have_http_status(:success)
    end
  end

  describe "Show Page" do
    it "renders attributes, cast table, and engagement stats" do
      create(:credit, movie: movie, cast: cast_member, character: "Lead")
      create(:review, movie: movie)
      create(:like, member: create(:member), likeable: movie)

      get admin_movie_path(movie)
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Lead")
      expect(response.body).to include("Total Reviews")
    end
  end

  describe "Form Actions" do
    it "successfully creates a movie with permitted params" do
      expect {
        post admin_movies_path, params: {
          movie: {
            title: "Avatar",
            tmdb_id: 19995,
            status: "released",
            release_date: "2009-12-18",
            runtime: 162,
            language: "en",
            synopsis: "A paraplegic Marine dispatched to the moon Pandora."
          }
        }
      }.to change(Movie, :count).by(1)
      expect(response).to redirect_to(admin_movie_path(Movie.last))
    end
  end

  describe "Batch Actions" do
    it "triggers mark_as_released logic" do
      movie.update(status: :unreleased) 
      
      post batch_action_admin_movies_path, params: {
        batch_action: 'mark_as_released',
        collection_selection: [movie.id]
      }
      
      expect(movie.reload.status).to eq('released')
      expect(movie.release_date).to eq(Date.today)
      expect(response).to redirect_to(admin_movies_path)
    end
  end

  describe "Form Rendering (Line Coverage for Form Block)" do
    it "renders the new movie form and all inputs" do
      get new_admin_movie_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Movie Details')
      expect(response.body).to include('input id="movie_tmdb_id"')
      expect(response.body).to include('input id="movie_title"')
      expect(response.body).to include('input id="movie_origin_country"')
    end

    it "renders the edit movie form" do
      get edit_admin_movie_path(movie)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(movie.title)
    end
  end

  describe "Form Submission" do
    it "successfully creates a movie" do
      expect {
        post admin_movies_path, params: {
          movie: {
            title: "Interstellar",
            tmdb_id: 157336,
            status: "released",
            release_date: "2014-11-07",
            runtime: 169,
            language: "en",
            synopsis: "A team of explorers travel through a wormhole in space."
          }
        }
      }.to change(Movie, :count).by(1)
    end
  end
end