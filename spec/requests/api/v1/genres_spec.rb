require 'rails_helper'

RSpec.describe "Api::V1::Genres", type: :request do
  let!(:genre) { create(:genre, name: "Sci-Fi") }
  let(:moderator) { create(:moderator).user }
  let(:member) { create(:member).user }

  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns genres list" do
      get api_v1_genres_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "returns specific genre" do
      get api_v1_genre_path(genre)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sci-Fi")
    end

    it "returns 404 for missing genre" do
      get api_v1_genre_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    let(:valid_params) { { genre: { name: "Horror" } } }

    it "allows moderator to create" do
      sign_in_as(moderator)
      expect { post api_v1_genres_path, params: valid_params }.to change(Genre, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns 422 on validation failure" do
      sign_in_as(moderator)
      post api_v1_genres_path, params: { genre: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "denies member" do
      sign_in_as(member)
      post api_v1_genres_path, params: valid_params
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /update" do
    it "updates successfully" do
      sign_in_as(moderator)
      patch api_v1_genre_path(genre), params: { genre: { name: "Thriller" } }
      expect(genre.reload.name).to eq("Thriller")
      expect(response).to have_http_status(:ok)
    end

    it "returns 422 on update failure" do
      sign_in_as(moderator)
      patch api_v1_genre_path(genre), params: { genre: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /destroy" do
    it "deletes genre" do
      sign_in_as(moderator)
      expect { delete api_v1_genre_path(genre) }.to change(Genre, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end