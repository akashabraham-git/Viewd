require 'rails_helper'

RSpec.describe "Api::V1::Movies", type: :request do
  let!(:member) { create(:member) }
  let!(:moderator) { create(:moderator) }
  
  let(:member_user) { member.user }
  let(:moderator_user) { moderator.user }

  let!(:movie) { create(:movie, title: "Inception") }
  let!(:genre_action) { create(:genre, name: "Action") }
  
  let!(:movie_a) { create(:movie, title: "Old Action", status: :released, release_date: 6.months.ago, synopsis: "This is a long enough synopsis") }
  let!(:movie_b) { create(:movie, title: "New Comedy", status: :released, release_date: 1.day.ago, synopsis: "This is also a long enough synopsis") }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /api/v1/movies" do
    context "when fetching the list" do
      before { get api_v1_movies_path }

      it "returns a successful response", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies']).not_to be_empty
      end
    end
  end

  describe "GET /show" do
    context "when the movie exists" do
      before { get api_v1_movie_path(movie) }

      it "returns 200 OK and renders the movie", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end
    end

    context "when the movie does not exist" do
      before { get "/api/v1/movies/999999" }

      it "returns 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Movie not found")
      end
    end
  end

  describe "POST /api/v1/movies" do
    let(:valid_params) { { movie: { title: "New Movie", synopsis: "A great film", release_date: "2024-01-01" } } }

    context "when user is a moderator" do
      before do
        sign_in_as(moderator_user)
        post api_v1_movies_path, params: valid_params
      end

      it "creates the movie and returns 201 Created", :aggregate_failures do
        expect(response).to have_http_status(:created)
        expect(Movie.find_by(title: "New Movie")).to be_present
      end
    end

    context "when user is a member (not authorized)" do
      before do
        sign_in_as(member_user)
        post api_v1_movies_path, params: valid_params
      end

      it "returns 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with invalid parameters" do
      before do
        sign_in_as(moderator_user)
        post api_v1_movies_path, params: { movie: { title: "" } } 
      end

      it "returns 422 Unprocessable Entity" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/v1/movies/:id" do
    let(:new_title) { "Updated Title" }

    context "when authorized" do
      before do
        sign_in_as(moderator_user)
        patch api_v1_movie_path(movie), params: { movie: { title: new_title } }
      end

      it "updates the movie", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(movie.reload.title).to eq(new_title)
      end
    end

    context "with invalid parameters" do
      before do
        sign_in_as(moderator_user)
        patch api_v1_movie_path(movie), params: { movie: { synopsis: "Too short" } }
      end

      it "returns 422 Unprocessable Entity" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to be_present
      end
    end
  end

  describe "DELETE /api/v1/movies/:id" do
    context "when authorized" do
      before do
        sign_in_as(moderator_user)
      end

      it "deletes the movie" do
        expect {
          delete api_v1_movie_path(movie)
        }.to change(Movie, :count).by(-1)
        
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not signed in (401)" do
      it "returns 401 Unauthorized" do
        delete api_v1_movie_path(movie)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a Member (403)" do
      it "returns 403 Forbidden" do
        sign_in_as(member_user) 
        delete api_v1_movie_path(movie)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when database deletion fails" do
      it "returns error status", :aggregate_failures do
        sign_in_as(moderator_user)
        
        allow(Movie).to receive(:find).with(movie.id.to_s).and_return(movie)
        allow(movie).to receive(:destroy).and_return(false)
        allow(movie).to receive_message_chain(:errors, :full_messages).and_return(["Cannot delete this movie"])

        delete api_v1_movie_path(movie)
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["error"]).to eq("Cannot delete this movie")
      end
    end
  end

  describe "GET /api/v1/movies/discover" do
    before do
      allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    end

    it "returns only released movies" do
      unreleased = create(:movie, status: :unreleased, synopsis: "Long enough synopsis")
      get "/api/v1/movies/discover"
      json = JSON.parse(response.body)
      
      expect(json.map { |m| m['id'] }).not_to include(unreleased.id)
    end

    it "orders by recency when mode is 'new'" do
      get "/api/v1/movies/discover", params: { mode: 'new' }
      json = JSON.parse(response.body)
      
      expect(json.map { |m| m['id'] }).to include(movie_b.id)
    end

    it "sorts by 'top' (average rating)" do
      create(:rating, movie: movie_a, rating: 5, member: member)
      create(:rating, movie: movie_b, rating: 1, member: create(:member))

      get "/api/v1/movies/discover", params: { mode: 'top' }
      json = JSON.parse(response.body)
      
      expect(json.first['id']).to eq(movie_a.id)
    end
  end

  describe "GET /api/v1/movies/recommend" do
    before do
      allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    end

    context "as a signed-in member" do
      before { sign_in_as(member_user) }

      it "calls the recommended_for scope on Movie" do
        expect(Movie).to receive(:recommended_for).with(member).and_call_original
        get "/api/v1/movies/recommend"
        expect(response).to have_http_status(:ok)
      end
    end

    context "as a guest" do
      it "falls back to recent released movies" do
        allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(nil)
        get "/api/v1/movies/recommend"
        json = JSON.parse(response.body)
        
        movie_ids = json.map { |m| m['id'] }
        expect(movie_ids).to include(movie_b.id)
        expect(movie_ids).to include(movie_a.id)
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end