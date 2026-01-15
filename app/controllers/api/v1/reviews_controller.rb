module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :doorkeeper_authorize!, only: [:index, :show]
      before_action :set_movie, only: [:index, :create]
      before_action :set_review, only: [:show, :update, :destroy]
      before_action :authorize_member!, only: :create
      before_action :authorize_owner!, only: [:update, :destroy]

      def index
        @reviews = @movie.reviews
                         .left_joins(:likes)
                         .group(:id)
                         .order('COUNT(likes.id) DESC, reviews.created_at DESC')
                         .includes(member: { profile_picture_attachment: :blob })
        
        render 'api/v1/reviews/index'
      end

      def show
        @rating = Rating.find_by(member: @review.member, movie: @review.movie)&.rating
        render 'api/v1/reviews/show'
      end

      def create
        @review = Review.new(review_params.merge(movie: @movie, member: current_user.actable))
        @review.current_user_instance = current_user
        
        if @review.save
          render 'api/v1/reviews/show', status: :created
        else
          render_error(@review.errors.full_messages.to_sentence)
        end
      end

      def update
        if @review.update(review_params)
          render 'api/v1/reviews/show', status: :ok
        else
          render_error(@review.errors.full_messages.to_sentence)
        end
      end

      def destroy
        
        if @review.destroy
          render_success("Review deleted", :ok)
        else
          render_error("Could not delete review")
        end
      end

      private

      def set_movie
        @movie = Movie.find_by(id: params[:movie_id])
        return render_error("Movie not found", :not_found) if @movie.nil?
      end

      def set_review
        @review = Review.find_by(id: params[:id])
        return render_error("Review not found", :not_found) if @review.nil?
        @movie = @review.movie
      end

      def authorize_member!
        if current_user&.actable_type == 'Moderator'
          render json: { error: "Only Members can do that." }, status: :forbidden
        end
      end

      def authorize_owner!
        unless current_user.actable == @review.member
          render json: { error: "Only review owner can do that." }, status: :forbidden
        end
      end

      def review_params
        params.require(:review).permit(:content)
      end
    end
  end
end