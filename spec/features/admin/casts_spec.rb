require 'rails_helper'

RSpec.describe "Admin::Casts", type: :feature do
  let!(:admin) { create(:admin_user, email: 'admin@example.com', password: 'password', password_confirmation: 'password') }
  let!(:movie) { create(:movie, title: "Inception") }
  let!(:cast)  { create(:cast, name: "Leonardo DiCaprio", pic: "https://example.com/leo.jpg") }
  let!(:credit) { create(:credit, cast: cast, movie: movie, job: "Actor", character: "Cobb") }

  before do
    visit new_admin_user_session_path
    fill_in "admin_user_email", with: admin.email
    fill_in "admin_user_password", with: 'password'
    click_button "Login"
  end

  describe "Index & Scopes" do
    it "renders the list and filters" do
      visit admin_casts_path
      expect(page).to have_content("Leonardo DiCaprio")
      
      visit admin_casts_path(q: { credits_job_eq: "Actor" })
      expect(page).to have_content("Leonardo DiCaprio")
    end

    it "responds to custom scopes" do
      visit admin_casts_path(scope: 'actors')
      expect(page).to have_http_status(:ok)
    end
  end

  describe "Show Page" do
    it "renders the filmography panels" do
      visit admin_cast_path(cast)
      expect(page).to have_content("As Actor")
      expect(page).to have_content("Inception")
    end
  end

  describe "CRUD" do
    it "updates name" do
      visit edit_admin_cast_path(cast)
      fill_in "cast_name", with: "Leo"
      click_button "Update Cast"
      
      expect(page).to have_current_path(admin_cast_path(cast))
      expect(cast.reload.name).to eq("Leo")
    end
  end

  describe "Form & CRUD" do
    it "renders the form fields" do
      visit edit_admin_cast_path(cast)
      expect(page).to have_field("cast_name")
      expect(page).to have_field("cast_tmdb_id")
    end

    it "submits the form to create a new cast" do
      visit new_admin_cast_path
      
      expect {
        fill_in "cast_name", with: "Tom Hardy"
        fill_in "cast_tmdb_id", with: "12345"
        fill_in "cast_bio", with: "British actor."
        click_button "Create Cast"
      }.to change(Cast, :count).by(1)
      
      expect(page).to have_current_path(admin_cast_path(Cast.last))
    end

    it "updates via the form" do
      visit edit_admin_cast_path(cast)
      fill_in "cast_name", with: "Leo"
      click_button "Update Cast"
      expect(page).to have_current_path(admin_cast_path(cast))
    end
  end
end