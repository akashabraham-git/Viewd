require 'rails_helper'

RSpec.describe "Admin::Movies", type: :feature do
  let!(:admin) { create(:admin_user, email: 'admin@example.com', password: 'password', password_confirmation: 'password') }
  let!(:movie) { create(:movie, title: "Inception", status: :unreleased) }
  let!(:cast_member) { create(:cast, name: "Leo") }

  before do
    visit new_admin_user_session_path
    
    fill_in "admin_user_email", with: admin.email
    fill_in "admin_user_password", with: 'password'
    click_button "Login"
    
    expect(page).to have_content("Dashboard")
  end

  describe "Index Page" do
    it "displays custom columns and average rating" do
      create(:rating, movie: movie, rating: 4)
      visit admin_movies_path
      
      expect(page).to have_content("Inception")
      expect(page).to have_content("4.0 / 5")
    end
  end

  describe "Show Page" do
    it "renders cast credits" do
      create(:credit, movie: movie, cast: cast_member, character: "Cobb")
      visit admin_movie_path(movie)
      
      expect(page).to have_content("Cobb")
      expect(page).to have_content("Inception")
    end
  end

  describe "Form Submission (Create)" do
    it "creates a new movie" do
      visit new_admin_movie_path
      
      fill_in "movie_title", with: "Avatar"
      fill_in "movie_tmdb_id", with: "12345"
      select "released", from: "movie_status"
      
      fill_in "movie_synopsis", with: "A high-budget sci-fi epic on the moon Pandora."
      
      click_button "Create Movie"
      
      expect(page).to have_content("Movie was successfully created")
      expect(Movie.find_by(title: "Avatar")).to be_present
    end
  end

end




