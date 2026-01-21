module Api
  module V1
    class LikesController < BaseController
      before_action :set_movie, only: [:create_movie_like, :destroy_movie_like]
      before_action :set_review, only: [:create_review_like, :destroy_review_like]

      def create_movie_like
        like = @movie.likes.find_or_create_by!(member: current_user.actable)
        render_like_status(@movie, "Movie liked", true)
      end

      def destroy_movie_like
        @movie.likes.where(member: current_user.actable).destroy_all
        render_like_status(@movie, "Movie unliked", false)
      end

      def create_review_like
        @review.likes.find_or_create_by!(member: current_user.actable)
        render_like_status(@review, "Review liked", true)
      end

      def destroy_review_like
        @review.likes.where(member: current_user.actable).destroy_all
        render_like_status(@review, "Review unliked", false)
      end

      private

      def render_like_status(likeable, message, liked)
        render json: { 
          message: message, 
          liked: liked,
          likes_count: likeable.likes.count 
        }, status: :ok
      end

      def set_movie
        @movie = Movie.find_by(id: params[:id])
        return render_error("Movie not found", :not_found) unless @movie
      end

      def set_review
        @review = Review.find_by(id: params[:id])
        return render_error("Review not found", :not_found) unless @review
      end
    end
  end
end