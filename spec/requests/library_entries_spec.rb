require 'rails_helper'

RSpec.describe "LibraryEntries", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(user).to receive(:actable).and_return(member_record)
  end

  describe "POST /toggle_watched" do
    context "when entry is not watched" do
      it "sets watched_date and removes from watchlist" do
        post "/movies/#{movie.id}/toggle_watched"
        
        entry = LibraryEntry.find_by(member: member_record, movie: movie)
        expect(entry.watched_date).to eq(Date.today)
        expect(entry.in_watchlist).to be false
      end
    end

    context "when entry is already watched" do
      it "removes watched_date and puts back in watchlist to pass validation" do
        entry = LibraryEntry.create!(
          member: member_record, 
          movie: movie, 
          watched_date: Date.yesterday, 
          in_watchlist: true 
        )
        
        post "/movies/#{movie.id}/toggle_watched"
        
        expect(entry.reload.watched_date).to be_nil
        expect(entry.in_watchlist).to be true
      end
    end
  end

  describe "POST /toggle_watchlist" do
    it "toggles in_watchlist attribute" do
      post "/movies/#{movie.id}/toggle_watchlist"
      entry = LibraryEntry.find_by(member: member_record, movie: movie)
      expect(entry.in_watchlist).to be true

      entry.update!(watched_date: Date.today)

      post "/movies/#{movie.id}/toggle_watchlist"
      expect(entry.reload.in_watchlist).to be false
    end
  end

  describe "Movie Not Found" do
    it "redirects to movies_path when movie id is invalid" do
      post "/movies/0/toggle_watched"
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Error: Movie not found.")
    end
  end

  describe "Activity Restriction (has_rating || has_review)" do
    before do
      LibraryEntry.create!(member: member_record, movie: movie, watched_date: Date.yesterday)
    end

    it "redirects with alert if rating exists" do
      create(:rating, member: member_record, movie: movie)
      
      post "/movies/#{movie.id}/toggle_watched"
      
      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:alert]).to eq("Can't be removed from your films since there's an activity in it.")
    end

    it "redirects with alert if review exists" do
      create(:review, member: member_record, movie: movie)
      
      post "/movies/#{movie.id}/toggle_watched"
      
      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:alert]).to eq("Can't be removed from your films since there's an activity in it.")
    end
  end
end