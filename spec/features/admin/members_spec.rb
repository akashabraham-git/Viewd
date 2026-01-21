require 'rails_helper'

RSpec.describe "Admin::Members", type: :feature do
  let!(:admin_user) { create(:admin_user, email: 'admin@example.com', password: 'password', password_confirmation: 'password') }
  let!(:member) { create(:member) }
  let!(:user) { member.user }

  before do
    visit new_admin_user_session_path
    fill_in "admin_user_email", with: admin_user.email
    fill_in "admin_user_password", with: 'password'
    click_button "Login"
    
    expect(page).to have_content("Dashboard")
  end

  describe "Index page" do
    it "renders the member list with user details" do
      visit admin_members_path
      expect(page).to have_content(user.username)
      expect(page).to have_content(user.email)
    end

    it "filters members by username" do
      visit admin_members_path(q: { user_username_cont: user.username })
      expect(page).to have_content(user.username)
      
      visit admin_members_path(q: { user_username_cont: "nonexistent" })
      expect(page).not_to have_content(user.username)
    end
  end
  

  describe "Show page" do
    it "renders member attributes and panels" do
      visit admin_member_path(member)
      expect(page).to have_content("Membership Details")
      expect(page).to have_content("Connection Stats")
    end

    it "contains links to connections" do
      visit admin_member_path(member)
      expect(page).to have_link("View Following List")
      expect(page).to have_link("View Followers List")
    end
  end

  describe "Controller Logic (Update)" do
    context "when password params are blank" do
      it "updates the user without changing the password" do
        visit edit_admin_member_path(member)
        
        fill_in "member_user_attributes_username", with: "new_username"
        fill_in "member_user_attributes_password", with: ""
        fill_in "member_user_attributes_password_confirmation", with: ""
        
        click_button "Update Member"
        
        expect(page).to have_current_path(admin_member_path(member))
        user.reload
        expect(user.username).to eq("new_username")
        expect(user.encrypted_password).to be_present 
      end
    end

    context "when providing a new password" do
      it "updates the password successfully" do
        visit edit_admin_member_path(member)
        
        fill_in "member_user_attributes_password", with: "newpassword123"
        fill_in "member_user_attributes_password_confirmation", with: "newpassword123"
        
        click_button "Update Member"
        
        expect(page).to have_content("Member was successfully updated")
      end
    end
  end

  describe "Form Rendering" do
    it "renders the semantic form blocks" do
      visit edit_admin_member_path(member)
      expect(page).to have_content("User Account")
      expect(page).to have_content("Member Profile")
    end
  end
end