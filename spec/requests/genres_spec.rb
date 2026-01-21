require 'rails_helper'

RSpec.describe "Genres", type: :request do
  let!(:genre) { create(:genre, name: "Sci-Fi") }
  let(:moderator) { create(:moderator).user }
  let(:member) { create(:member).user }

  def sign_in_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    before { sign_in_as(moderator) }
    
    it "renders the index template" do
      get genres_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "renders the show template" do
      get genre_path(genre)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    before { sign_in_as(moderator) }
    
    it "renders the new template" do
      get new_genre_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "as a moderator" do
      before { sign_in_as(moderator) }

      it "creates a genre with valid params" do
        expect {
          post genres_path, params: { genre: { name: "Horror" } }
        }.to change(Genre, :count).by(1)
        expect(response).to redirect_to(genres_path)
      end

      it "renders new on failure" do
        post genres_path, params: { genre: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to be_present
      end
    end

    context "as a member" do
      it "denies access" do
        sign_in_as(member)
        post genres_path, params: { genre: { name: "Action" } }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET /edit" do
    before { sign_in_as(moderator) }
    
    it "renders the edit template" do
      get edit_genre_path(genre)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    before { sign_in_as(moderator) }

    it "updates with valid params" do
      patch genre_path(genre), params: { genre: { name: "Science Fiction" } }
      expect(genre.reload.name).to eq("Science Fiction")
      expect(response).to redirect_to(genres_path)
    end

    it "renders edit on failure" do
      patch genre_path(genre), params: { genre: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /destroy" do
    before { sign_in_as(moderator) }

    it "deletes the genre" do
      expect {
        delete genre_path(genre)
      }.to change(Genre, :count).by(-1)
      expect(response).to redirect_to(genres_path)
    end
  end
end