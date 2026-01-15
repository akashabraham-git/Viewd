module Api
  module V1
    class LikesController < BaseController
      before_action :set_movie, only: :toggle_movie_like

      def toggle_movie_like
        like = @movie.likes.find_by(member: current_user.actable)

        if like
          like.destroy
          render json: { 
            message: "Movie unliked", 
            liked: false,
            likes_count: @movie.likes.count 
          }, status: :ok
        else
          @movie.likes.create!(member: current_user.actable)
          render json: { 
            message: "Movie liked", 
            liked: true,
            likes_count: @movie.likes.count 
          }, status: :ok
        end
      end

      def toggle_review_like
        @review = Review.find_by(id: params[:id])
        return render_error("Review not found", :not_found) if @review.nil?

        @like = @review.likes.find_by(member: current_user.actable)

        if @like
          @like.destroy
          render json: { 
            message: "Review unliked", 
            liked: false,
            likes_count: @review.likes.count 
          }, status: :ok
        else
          @review.likes.create(member: current_user.actable)
          render json: { 
            message: "Review liked", 
            liked: true,
            likes_count: @review.likes.count 
          }, status: :ok
        end
      end

      private

      def set_movie
        movie_id = params[:movie_id] || params[:id] 
        @movie = Movie.find_by(id: movie_id)
        return render_error("Movie not found", :not_found) if @movie.nil?
      end
    end
  end
end