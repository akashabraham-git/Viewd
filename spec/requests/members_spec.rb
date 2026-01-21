require 'rails_helper'

RSpec.describe "Members", type: :request do
  let!(:member_record) { create(:member) }
  let(:member_user) { member_record.user }
  let!(:moderator_user) { create(:moderator).user }
  let!(:movie) { create(:movie, title: "Inception") }

  def sign_in_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /watchlist" do
    context "as a member" do
      before { sign_in_as(member_user) }
      it "renders the watchlist and shows the movie title" do
        create(:library_entry, member: member_record, movie: movie, in_watchlist: true)
        get watchlist_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end
    end
  end

  describe "GET /likes" do
    context "as a member" do
      before { sign_in_as(member_user) }
      it "renders liked movies" do
        create(:like, member: member_record, likeable: movie)
        get likes_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end
    end
  end

  describe "GET /library" do
    context "as a member" do
      before { sign_in_as(member_user) }
      it "renders watched movies" do
        create(:library_entry, member: member_record, movie: movie, watched_date: Date.today)
        get library_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end
    end
  end

  describe "GET /reviews" do
    context "as a member" do
      before { sign_in_as(member_user) }
      it "renders member reviews" do
        create(:review, member: member_record, movie: movie, content: "Great movie!")
        get reviews_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Great movie!")
      end
    end
  end

  describe "set_member" do
    it "redirects to root if member does not exist" do
      sign_in_as(member_user)
      get watchlist_member_path(id: 0)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Invalid user")
    end
  end

  describe "Moderator Redirection" do
    before { sign_in_as(moderator_user) }

    it "redirects watchlist for non-members" do
      get watchlist_member_path(member_record)
      expect(response).to redirect_to(user_path(member_record.user))
      expect(flash[:alert]).to eq("Watchlist is only available for members.")
    end

    it "redirects likes for non-members" do
      get likes_member_path(member_record)
      expect(response).to redirect_to(user_path(member_record.user))
      expect(flash[:alert]).to eq("Likes are only available for members.")
    end

    it "redirects library for non-members" do
      get library_member_path(member_record)
      expect(response).to redirect_to(user_path(member_record.user))
      expect(flash[:alert]).to eq("Library is only available for members.")
    end

    it "redirects reviews for non-members" do
      get reviews_member_path(member_record)
      expect(response).to redirect_to(user_path(member_record.user))
      expect(flash[:alert]).to eq("Reviews are only available for members.")
    end
  end
end