require 'rails_helper'

RSpec.describe "Admin::Users", type: :feature do
  let!(:admin) { create(:admin_user) }
  let!(:member_user) { create(:user, :as_member, name: "John Member", email: "john@example.com") }
  let!(:moderator_user) { create(:user, :as_moderator, name: "Jane Moderator") }

  before do
    visit new_admin_user_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123" 
    click_button "Login"
  end

  describe "Index Page and Scopes" do
    it "filters users by scope" do
      visit admin_users_path
      
      within ".scopes" do
        click_link "Member"
      end
      expect(page).to have_content("John Member")
      expect(page).not_to have_content("Jane Moderator")

      within ".scopes" do
        click_link "Moderator"
      end
      expect(page).to have_content("Jane Moderator")
      expect(page).not_to have_content("John Member")
    end
  end

  describe "Show Page" do
    it "renders actable details for Member and Moderator" do
      visit admin_user_path(member_user)
      expect(page).to have_content("Member")
      expect(page).to have_content(member_user.actable.bio)

      visit admin_user_path(moderator_user)
      expect(page).to have_content("Moderator")
    end
  end

  describe "Form and Controller Logic" do
    it "updates name without changing password" do
      visit edit_admin_user_path(member_user)
      
      fill_in "user_name", with: "Updated Name"
      fill_in "user_password", with: ""
      fill_in "user_password_confirmation", with: ""
      
      click_button "Update User"
      
      expect(page).to have_content("User was successfully updated")
      expect(member_user.reload.name).to eq("Updated Name")
    end

    it "updates the password" do
      visit edit_admin_user_path(member_user)
      
      fill_in "user_password", with: "newpassword123"
      fill_in "user_password_confirmation", with: "newpassword123"
      
      click_button "Update User"
      
      expect(page).to have_content("User was successfully updated")
    end
  end

  describe "Restricted Actions" do
    it "does not show the New User button" do
      visit admin_users_path
      expect(page).not_to have_link("New User")
    end
  end
end