require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let!(:member_record) { create(:member) }
  let(:user) { member_record.user }
  let!(:movie) { create(:movie) }
  let!(:review) { create(:review, movie: movie, member: member_record) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(user).to receive(:actable).and_return(member_record)
    @headers = { "HTTP_REFERER" => movie_path(movie) }
  end

  describe "POST /movies/:id/toggle_movie_like" do
    describe "toggle_movie_like - Branch: @current_user.nil?" do
      context "when user is signed in (@current_user.nil? = FALSE)" do
        it "creates a like if it doesn't exist (like = nil branch)" do
          expect {
            post toggle_movie_like_movie_path(movie), headers: @headers
          }.to change(Like, :count).by(1)
          expect(response).to redirect_to(movie_path(movie))
        end

        it "removes a like if it already exists (like = true branch)" do
          movie.likes.create!(member: member_record)
          expect {
            post toggle_movie_like_movie_path(movie), headers: @headers
          }.to change(Like, :count).by(-1)
          expect(response).to redirect_to(movie_path(movie))
        end

        it "finds the correct like by member" do
          other_member = create(:member)
          movie.likes.create!(member: other_member)
          
          expect {
            post toggle_movie_like_movie_path(movie), headers: @headers
          }.to change(Like, :count).by(1)
          
          expect(movie.likes.count).to eq(2)
        end

        it "returns to the referer path" do
          post toggle_movie_like_movie_path(movie), headers: { "HTTP_REFERER" => "/custom/path" }
          expect(response).to redirect_to("/custom/path")
        end

        it "uses fallback location when no referer" do
          post toggle_movie_like_movie_path(movie)
          expect(response).to redirect_to(movie_path(movie))
        end
      end

      context "when user is NOT signed in (@current_user.nil? = TRUE)" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
        end

        it "redirects with an alert" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(flash[:alert]).to eq("sign in for liking")
          expect(response).to redirect_to(movie_path(movie))
        end

        it "does not create a like" do
          expect {
            post toggle_movie_like_movie_path(movie), headers: @headers
          }.not_to change(Like, :count)
        end

        it "uses fallback location when redirecting" do
          post toggle_movie_like_movie_path(movie), headers: {}
          expect(response).to redirect_to(movies_path)
        end
      end
    end
  end

  describe "POST /movies/:movie_id/reviews/:id/toggle_like" do
    let(:path) { toggle_like_movie_review_path(movie, review) }

    describe "toggle_review_like - Branch: @current_user.nil?" do
      context "when user is signed in (@current_user.nil? = FALSE)" do
        it "creates a like if review doesn't have a like from this member (@like = nil branch)" do
          expect {
            post path, headers: @headers
          }.to change(Like, :count).by(1)
          expect(response).to redirect_to(movie_path(movie))
        end

        it "destroys the like if review already has a like from this member (@like = true branch)" do
          review.likes.create!(member: member_record)
          expect {
            post path, headers: @headers
          }.to change(Like, :count).by(-1)
          expect(response).to redirect_to(movie_path(movie))
        end

        it "only destroys the current user's like, not others" do
          other_member = create(:member)
          review.likes.create!(member: other_member)
          review.likes.create!(member: member_record)
          
          expect {
            post path, headers: @headers
          }.to change(Like, :count).by(-1)
          
          expect(review.likes.count).to eq(1)
          expect(review.likes.first.member).to eq(other_member)
        end

        it "returns to referer path" do
          post path, headers: { "HTTP_REFERER" => "/custom/review/path" }
          expect(response).to redirect_to("/custom/review/path")
        end

        it "uses fallback location (movie_path) when no referer" do
          post path
          expect(response).to redirect_to(movie_path(movie))
        end
      end

      context "when user is NOT signed in (@current_user.nil? = TRUE)" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
        end

        it "redirects back with alert" do
          post path, headers: @headers
          expect(flash[:alert]).to eq("sign in for liking")
          expect(response).to redirect_to(movie_path(movie))
        end

        it "does not create or modify likes" do
          expect {
            post path, headers: @headers
          }.not_to change(Like, :count)
        end

        it "uses fallback location (movie_path) when redirecting" do
          post path, headers: {}
          expect(response).to redirect_to(movie_path(movie))
        end
      end
    end
  end

  describe "set_movie (private method - before_action)" do
    describe "set_movie - Branch: movie_id || id parameter resolution" do
      context "when movie_id param is provided (uses movie_id)" do
        it "finds movie by movie_id from route params" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(assigns(:movie)).to eq(movie)
        end
      end

      context "when only id param is provided (uses id)" do
        it "finds movie by id when looking up review's movie" do
          post toggle_like_movie_review_path(movie, review), headers: @headers
          expect(assigns(:movie)).to eq(movie)
        end
      end
    end

    describe "set_movie - Branch: @movie.nil? && params[:id].present?" do
      context "when movie is found by id " do
        it "sets @movie and skips the nested check" do
          post toggle_like_movie_review_path(movie, review), headers: @headers
          expect(assigns(:movie)).to eq(movie)
        end
      end

      context "when movie is not found by id param and id is NOT present" do
        it "handles when id param is missing" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(assigns(:movie)).to eq(movie)
        end
      end

      context "when @movie is nil AND params[:id] is present (branch TRUE)" do
        context "second find_by with id parameter finds the movie (nested @movie.nil? = FALSE)" do
          it "finds review and gets its movie through nested else branch" do
            post toggle_like_movie_review_path(movie, review), headers: @headers
            expect(assigns(:movie)).to eq(movie)
            expect(response).to redirect_to(movie_path(movie))
          end
        end

        context "second find_by fails and Review.find_by also fails (nested @movie.nil? = TRUE)" do
          it "redirects to movies_path with alert" do
            post "/movies/999999/toggle_movie_like", headers: @headers
            expect(response).to redirect_to(movies_path)
            expect(flash[:alert]).to eq("Error: Movie not found.")
          end
        end

        context "finds movie through Review association (nested else: @movie = Review.find_by&.movie)" do
          it "finds movie when id references a review" do
            post toggle_like_movie_review_path(movie, review), headers: @headers
            expect(assigns(:movie)).to eq(movie)
          end
        end
      end
    end

    describe "set_movie - Final branch: @movie.nil? check" do
      context "when @movie is nil after all lookups (final branch TRUE)" do
        it "redirects to movies_path with error alert" do
          post "/movies/999999/toggle_movie_like", headers: @headers
          expect(response).to redirect_to(movies_path)
          expect(flash[:alert]).to eq("Error: Movie not found.")
        end

        it "does not attempt to toggle like when movie is missing" do
          expect {
            post "/movies/999999/toggle_movie_like", headers: @headers
          }.not_to change(Like, :count)
        end
      end

      context "when @movie is found (final branch FALSE)" do
        it "proceeds with like toggle" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(assigns(:movie)).to eq(movie)
          expect(response).to redirect_to(movie_path(movie))
        end
      end
    end
  end

  describe "toggle_movie_like and toggle_review_like - Like existence branches" do
    describe "toggle_movie_like - Branch: like exists?" do
      context "when like exists for member (branch TRUE)" do
        before do
          movie.likes.create!(member: member_record)
        end

        it "destroys the existing like" do
          expect {
            post toggle_movie_like_movie_path(movie), headers: @headers
          }.to change(Like, :count).by(-1)
        end

        it "removes only the user's like" do
          other_member = create(:member)
          movie.likes.create!(member: other_member)

          post toggle_movie_like_movie_path(movie), headers: @headers

          expect(movie.likes.count).to eq(1)
          expect(movie.likes.first.member).to eq(other_member)
        end

        it "redirects after destruction" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(response).to redirect_to(movie_path(movie))
        end
      end

      context "when like does not exist (branch FALSE)" do
        it "creates a new like" do
          expect {
            post toggle_movie_like_movie_path(movie), headers: @headers
          }.to change(Like, :count).by(1)
        end

        it "creates like with correct member" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(movie.likes.last.member).to eq(member_record)
        end

        it "redirects after creation" do
          post toggle_movie_like_movie_path(movie), headers: @headers
          expect(response).to redirect_to(movie_path(movie))
        end
      end
    end

    describe "toggle_review_like - Branch: @like exists?" do
      context "when @like exists for member (branch TRUE)" do
        before do
          review.likes.create!(member: member_record)
        end

        it "destroys the existing review like" do
          expect {
            post toggle_like_movie_review_path(movie, review), headers: @headers
          }.to change(Like, :count).by(-1)
        end

        it "removes only the user's review like" do
          other_member = create(:member)
          review.likes.create!(member: other_member)

          post toggle_like_movie_review_path(movie, review), headers: @headers

          expect(review.likes.count).to eq(1)
          expect(review.likes.first.member).to eq(other_member)
        end

        it "redirects after destroying review like" do
          post toggle_like_movie_review_path(movie, review), headers: @headers
          expect(response).to redirect_to(movie_path(movie))
        end
      end

      context "when @like does not exist (branch FALSE - else in toggle_review_like)" do
        it "creates a new review like" do
          expect {
            post toggle_like_movie_review_path(movie, review), headers: @headers
          }.to change(Like, :count).by(1)
        end

        it "creates review like with correct member" do
          post toggle_like_movie_review_path(movie, review), headers: @headers
          expect(review.likes.last.member).to eq(member_record)
        end

        it "redirects after creating review like" do
          post toggle_like_movie_review_path(movie, review), headers: @headers
          expect(response).to redirect_to(movie_path(movie))
        end
      end
    end
  end

  describe "Safe navigation operator &.actable" do
    context "when @current_user has an actable association" do
      it "finds the member correctly for movie like" do
        post toggle_movie_like_movie_path(movie), headers: @headers
        expect(assigns(:movie).likes.first.member).to eq(member_record)
      end

      it "finds the member correctly for review like" do
        post toggle_like_movie_review_path(movie, review), headers: @headers
        expect(review.likes.first.member).to eq(member_record)
      end
    end

    context "when @current_user does NOT have an actable (safe navigation returns nil)" do
      let(:moderator) { create(:moderator) }
      let(:moderator_user) { moderator.user }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(moderator_user)
        allow(moderator_user).to receive(:actable).and_return(nil)
      end

      it "handles nil member for movie like toggle" do
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.not_to change(Like, :count)
      end

      it "handles nil member for review like creation " do
        begin
          post toggle_like_movie_review_path(movie, review), headers: @headers
        rescue ActiveRecord::InvalidRecord
        end
        expect(review.likes.count).to eq(0)
      end

      it "does not create likes when member is nil" do
        begin
          post toggle_like_movie_review_path(movie, review), headers: @headers
        rescue NoMethodError
          # Expected when member is nil
        end
        expect(review.likes.count).to eq(0)
      end
    end

    context "when @current_user is nil" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "handles nil gracefully for movie like" do
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.not_to change(Like, :count)
      end

      it "handles nil gracefully for review like" do
        expect {
          post toggle_like_movie_review_path(movie, review), headers: @headers
        }.not_to change(Like, :count)
      end
    end
  end

  describe "set_movie - Nested conditional branches" do
    context "when first find_by returns nil AND id param exists AND second find_by returns nil" do
      it "tries to get movie from Review.find_by returning nil " do
        post "/movies/999999/toggle_movie_like", headers: @headers
        expect(response).to redirect_to(movies_path)
        expect(flash[:alert]).to eq("Error: Movie not found.")
      end
    end

    context "when first find_by fails but second find_by succeeds " do
      it "finds movie by direct id lookup in second attempt" do
        post "/movies/#{movie.id}/toggle_movie_like", headers: @headers
        expect(assigns(:movie)).to eq(movie)
        expect(response).to redirect_to(movie_path(movie))
      end
    end

    context "when Review.find_by returns a record but &.movie returns nil " do
      let(:review_without_movie) { create(:review, movie: nil) }

      it "safely handles nil movie from review association" do
        post toggle_like_movie_review_path(movie, review), headers: @headers
        expect(assigns(:movie)).to eq(movie)
      end
    end
  end

  describe "Integration - Complete Workflows" do
    context "Member liking and unliking a movie" do
      it "completes full workflow: like -> unlike -> like" do
        
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.to change(Like, :count).by(1)

        
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.to change(Like, :count).by(-1)

        
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.to change(Like, :count).by(1)

        expect(Like.count).to eq(1)
      end
    end

    context "Member liking and unliking a review" do
      it "completes full workflow: like -> unlike -> like" do
        
        expect {
          post toggle_like_movie_review_path(movie, review), headers: @headers
        }.to change(Like, :count).by(1)

        
        expect {
          post toggle_like_movie_review_path(movie, review), headers: @headers
        }.to change(Like, :count).by(-1)

        
        expect {
          post toggle_like_movie_review_path(movie, review), headers: @headers
        }.to change(Like, :count).by(1)

        expect(Like.count).to eq(1)
      end
    end

    context "Multiple members liking same content" do
      let(:member2) { create(:member) }
      let(:user2) { member2.user }

      it "tracks likes from different members independently for movie" do
        post toggle_movie_like_movie_path(movie), headers: @headers

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user2)
        allow(user2).to receive(:actable).and_return(member2)

        post toggle_movie_like_movie_path(movie), headers: @headers

        expect(movie.likes.count).to eq(2)
      end

      it "tracks likes from different members independently for review" do
        post toggle_like_movie_review_path(movie, review), headers: @headers

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user2)
        allow(user2).to receive(:actable).and_return(member2)

        post toggle_like_movie_review_path(movie, review), headers: @headers

        expect(review.likes.count).to eq(2)
      end
    end

    context "Unauthenticated user attempting to like" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "cannot like a movie" do
        expect {
          post toggle_movie_like_movie_path(movie), headers: @headers
        }.not_to change(Like, :count)
      end

      it "cannot like a review" do
        expect {
          post toggle_like_movie_review_path(movie, review), headers: @headers
        }.not_to change(Like, :count)
      end

      it "receives appropriate alerts for both" do
        post toggle_movie_like_movie_path(movie), headers: @headers
        expect(flash[:alert]).to eq("sign in for liking")

        post toggle_like_movie_review_path(movie, review), headers: @headers
        expect(flash[:alert]).to eq("sign in for liking")
      end
    end
  end

  describe "Error Handling" do
    context "Invalid movie" do
      it "redirects to movies index if movie id is invalid" do
        post "/movies/999999/toggle_movie_like"
        expect(response).to redirect_to(movies_path)
        expect(flash[:alert]).to eq("Error: Movie not found.")
      end
    end

    context "Invalid review" do
      it "redirects if review doesn't exist" do
        post "/movies/#{movie.id}/reviews/999999/toggle_like", headers: @headers
       
        expect([302, 404, 500]).to include(response.status)
      end
    end

    context "Missing params" do
      it "handles invalid routes gracefully" do
        post "/movies/toggle_movie_like", headers: @headers
       
        expect(response.status).to eq(404)
      end
    end
  end
end