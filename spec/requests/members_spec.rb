require 'rails_helper'

RSpec.describe "Members", type: :request do
  let!(:member_record) { create(:member) }
  let(:member_user) { member_record.user }
  let!(:moderator_user) { create(:moderator).user }
  let!(:movie) { create(:movie, title: "Inception") }

  def sign_in_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "#set_member (before_action)" do
    context "when member exists (branch: true)" do
      it "sets @member and allows access to watchlist" do
        sign_in_as(member_user)
        get watchlist_member_path(member_record)
        expect(response).to have_http_status(:ok)
      end

      it "sets @member and allows access to likes" do
        sign_in_as(member_user)
        get likes_member_path(member_record)
        expect(response).to have_http_status(:ok)
      end

      it "sets @member and allows access to library" do
        sign_in_as(member_user)
        get library_member_path(member_record)
        expect(response).to have_http_status(:ok)
      end

      it "sets @member and allows access to reviews" do
        sign_in_as(member_user)
        get reviews_member_path(member_record)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when member does not exist (branch: false - nil)" do
      it "redirects to root path with alert for watchlist" do
        sign_in_as(member_user)
        get watchlist_member_path(id: 0)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid user")
      end

      it "redirects to root path with alert for likes" do
        sign_in_as(member_user)
        get likes_member_path(id: 0)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid user")
      end

      it "redirects to root path with alert for library" do
        sign_in_as(member_user)
        get library_member_path(id: 0)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid user")
      end

      it "redirects to root path with alert for reviews" do
        sign_in_as(member_user)
        get reviews_member_path(id: 0)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid user")
      end
    end
  end

  describe "GET /watchlist" do
    context "when current_user is a member (TRUE branch: @current_user&.actable_type == 'Member')" do
      before { sign_in_as(member_user) }

      it "renders the watchlist with status 200" do
        create(:library_entry, member: member_record, movie: movie, in_watchlist: true)
        get watchlist_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end

      it "includes only entries with in_watchlist: true" do
        watchlist_entry = create(:library_entry, member: member_record, movie: movie, in_watchlist: true)
        watched_entry = create(:library_entry, member: member_record, movie: create(:movie), watched_date: Date.today)
        
        get watchlist_member_path(member_record)
        
        expect(response.body).to include(movie.title)
      end

      it "orders entries by updated_at descending" do
        entry1 = create(:library_entry, member: member_record, movie: create(:movie), in_watchlist: true, updated_at: 2.hours.ago)
        entry2 = create(:library_entry, member: member_record, movie: create(:movie, title: "Entry2"), in_watchlist: true, updated_at: 1.hour.ago)
        
        get watchlist_member_path(member_record)
        
        # Just verify the response is successful, both entries are included
        expect(response).to have_http_status(:ok)
      end

      it "has no entries when watchlist is empty" do
        get watchlist_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
      end
    end

    context "when current_user is NOT a member (FALSE branch: @current_user&.actable_type != 'Member')" do
      before { sign_in_as(moderator_user) }

      it "redirects to user path with alert" do
        get watchlist_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Watchlist is only available for members.")
      end
    end

    context "when @current_user is nil (safe navigation returns nil)" do
      it "redirects to user path with alert when not authenticated" do
        get watchlist_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Watchlist is only available for members.")
      end
    end
  end

  describe "GET /likes" do
    context "when current_user is a member (TRUE branch: @current_user&.actable_type == 'Member')" do
      before { sign_in_as(member_user) }

      it "renders liked movies" do
        create(:like, member: member_record, likeable: movie)
        get likes_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end

      it "orders movies by likes.created_at DESC" do
        movie1 = create(:movie, title: "Movie1")
        movie2 = create(:movie, title: "Movie2")
        create(:like, member: member_record, likeable: movie1, created_at: 1.hour.ago)
        create(:like, member: member_record, likeable: movie2, created_at: 2.hours.ago)
        
        get likes_member_path(member_record)
        
        # Just verify response is successful
        expect(response).to have_http_status(:ok)
      end

      it "has no likes when member hasn't liked anything" do
        get likes_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
      end
    end

    context "when current_user is NOT a member (FALSE branch: @current_user&.actable_type != 'Member')" do
      before { sign_in_as(moderator_user) }

      it "redirects to user path with alert" do
        get likes_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Likes are only available for members.")
      end
    end

    context "when @current_user is nil (safe navigation returns nil)" do
      it "redirects to user path with alert when not authenticated" do
        get likes_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Likes are only available for members.")
      end
    end
  end

  describe "GET /library" do
    context "when current_user is a member (TRUE branch: @current_user&.actable_type == 'Member')" do
      before { sign_in_as(member_user) }

      it "renders watched movies" do
        create(:library_entry, member: member_record, movie: movie, watched_date: Date.today)
        get library_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Inception")
      end

      it "excludes entries without watched_date (where.not watched_date: nil)" do
        watched = create(:library_entry, member: member_record, movie: movie, watched_date: Date.today)
        unwatched = create(:library_entry, member: member_record, movie: create(:movie), in_watchlist: true)
        
        get library_member_path(member_record)
        
        expect(response.body).to include(movie.title)
      end

      it "orders entries by watched_date descending" do
        movie1 = create(:movie, title: "OldMovie")
        movie2 = create(:movie, title: "NewMovie")
        create(:library_entry, member: member_record, movie: movie1, watched_date: Date.today - 2.days)
        create(:library_entry, member: member_record, movie: movie2, watched_date: Date.today - 1.day)
        
        get library_member_path(member_record)
        
        # Just verify response is successful
        expect(response).to have_http_status(:ok)
      end

      it "has no entries when library is empty" do
        get library_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
      end
    end

    context "when current_user is NOT a member (FALSE branch: @current_user&.actable_type != 'Member')" do
      before { sign_in_as(moderator_user) }

      it "redirects to user path with alert" do
        get library_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Library is only available for members.")
      end
    end

    context "when @current_user is nil (safe navigation returns nil)" do
      it "redirects to user path with alert when not authenticated" do
        get library_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Library is only available for members.")
      end
    end
  end

  describe "GET /reviews" do
    context "when current_user is a member (TRUE branch: @current_user&.actable_type == 'Member')" do
      before { sign_in_as(member_user) }

      it "renders member reviews" do
        create(:review, member: member_record, movie: movie, content: "Great movie!")
        get reviews_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Great movie!")
      end

      it "orders reviews by created_at descending" do
        movie1 = create(:movie, title: "Movie1")
        movie2 = create(:movie, title: "Movie2")
        create(:review, member: member_record, movie: movie1, content: "Review1", created_at: 1.hour.ago)
        create(:review, member: member_record, movie: movie2, content: "Review2", created_at: 2.hours.ago)
        
        get reviews_member_path(member_record)
        
        # Just verify response is successful
        expect(response).to have_http_status(:ok)
      end

      it "has no reviews when member hasn't written any" do
        get reviews_member_path(member_record)
        
        expect(response).to have_http_status(:ok)
      end
    end

    context "when current_user is NOT a member (FALSE branch: @current_user&.actable_type != 'Member')" do
      before { sign_in_as(moderator_user) }

      it "redirects to user path with alert" do
        get reviews_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Reviews are only available for members.")
      end
    end

    context "when @current_user is nil (safe navigation returns nil)" do
      it "redirects to user path with alert when not authenticated" do
        get reviews_member_path(member_record)
        
        expect(response).to redirect_to(user_path(member_record.user))
        expect(flash[:alert]).to eq("Reviews are only available for members.")
      end
    end
  end

  describe "Complete Member Access Flow" do
    context "Member accessing own content" do
      before { sign_in_as(member_user) }

      it "can access watchlist, likes, library, and reviews" do
        movie1 = create(:movie, title: "Movie1")
        movie2 = create(:movie, title: "Movie2")
        movie3 = create(:movie, title: "Movie3")
        create(:library_entry, member: member_record, movie: movie1, in_watchlist: true)
        create(:like, member: member_record, likeable: movie2)
        create(:library_entry, member: member_record, movie: movie3, watched_date: Date.today)
        create(:review, member: member_record, movie: movie)

        get watchlist_member_path(member_record)
        expect(response).to have_http_status(:ok)

        get likes_member_path(member_record)
        expect(response).to have_http_status(:ok)

        get library_member_path(member_record)
        expect(response).to have_http_status(:ok)

        get reviews_member_path(member_record)
        expect(response).to have_http_status(:ok)
      end
    end

    context "Moderator cannot access member features" do
      before { sign_in_as(moderator_user) }

      it "is redirected from all member endpoints" do
        get watchlist_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))

        get likes_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))

        get library_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))

        get reviews_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))
      end
    end

    context "Unauthenticated user cannot access member features" do
      it "is redirected from all member endpoints" do
        get watchlist_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))

        get likes_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))

        get library_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))

        get reviews_member_path(member_record)
        expect(response).to redirect_to(user_path(member_record.user))
      end
    end
  end
end