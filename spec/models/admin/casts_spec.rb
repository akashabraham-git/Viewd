require 'rails_helper'

RSpec.describe "Admin::Casts", type: :request do
  let!(:admin) { create(:admin_user) }
  let!(:movie) { create(:movie, title: "Inception") }
  let!(:cast)  { create(:cast, name: "Leonardo DiCaprio", pic: "https://example.com/leo.jpg") }
  let!(:credit) { create(:credit, cast: cast, movie: movie, job: "Actor", character: "Cobb") }

  before { sign_in admin }

  describe "Index & Scopes" do
    it "renders the list and filters" do
      get admin_casts_path
      expect(response.body).to include("Leonardo DiCaprio")
      
      get admin_casts_path, params: { q: { credits_job_eq: "Actor" } }
      expect(response.body).to include("Leonardo DiCaprio")
    end

    it "responds to custom scopes" do
      get admin_casts_path, params: { scope: 'actors' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Show Page" do
    it "renders the filmography panels" do
      get admin_cast_path(cast)
      expect(response.body).to include("As Actor")
      expect(response.body).to include("Inception")
    end
  end

  describe "CRUD" do
    it "updates name" do
      patch admin_cast_path(cast), params: { cast: { name: "Leo" } }
      expect(response).to redirect_to(admin_cast_path(cast))
      expect(cast.reload.name).to eq("Leo")
    end
  end

  describe "Form & CRUD" do
    it "renders the form fields" do
      get edit_admin_cast_path(cast)
      expect(response.body).to include('name="cast[name]"')
      expect(response.body).to include('name="cast[tmdb_id]"')
    end

    it "submits the form to create a new cast" do
      expect {
        post admin_casts_path, params: { 
          cast: { 
            name: "Tom Hardy", 
            tmdb_id: "12345", 
            bio: "British actor." 
          } 
        }
      }.to change(Cast, :count).by(1)
      
      expect(response).to redirect_to(admin_cast_path(Cast.last))
    end

    it "updates via the form" do
      patch admin_cast_path(cast), params: { cast: { name: "Leo" } }
      expect(response).to redirect_to(admin_cast_path(cast))
    end
  end
end