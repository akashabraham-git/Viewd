# app/controllers/api/v1/ratings_controller.rb
module Api
  module V1
    class RatingsController < BaseController
      # POST /api/v1/movies/:id/rating
      def toggle
        @movie = Movie.find_by(id: params[:id])
        return render_error("Movie not found", :not_found) if @movie.nil?

        score = params[:rating].to_i

        existing_rating = Rating.find_by(member: current_user.actable, movie: @movie)

        if existing_rating && (score == 0 || existing_rating.rating == score)
          existing_rating.destroy
          render_success("Rating removed", :ok, { rated: false })
        else
          rating_record = Rating.find_or_initialize_by(member: current_user.actable, movie: @movie)
          rating_record.current_user_instance = current_user
          
          if rating_record.update(rating: score)
            render json: { 
              message: "Rating saved", 
              rating: rating_record.rating,
              rated: true 
            }, status: :ok
          else
            render_error(rating_record.errors.full_messages.to_sentence)
          end
        end
      end
    end
  end
end