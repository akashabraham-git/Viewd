module Api
  module V1
    class RatingsController < BaseController
      before_action :set_movie

      def create
        score = params[:rating].to_i
        return render_error("Invalid rating score", :unprocessable_content) if score <= 0

        @rating = Rating.new(member: current_user.actable, movie: @movie, rating: score)
        @rating.current_user_instance = current_user
        
        if @rating.save
          render_success("Rating created", :created)
        else
          render_error(@rating.errors.full_messages.to_sentence)
        end
      end

      def update
        score = params[:rating].to_i
        @rating = Rating.find_by(member: current_user.actable, movie: @movie)
        
        return render_error("Rating not found", :not_found) unless @rating
        return render_error("Invalid rating score", :unprocessable_content) if score <= 0

        @rating.current_user_instance = current_user
        if @rating.update(rating: score)
          render_success("Rating updated", :ok)
        else
          render_error(@rating.errors.full_messages.to_sentence)
        end
      end

      def destroy
        rating = Rating.find_by(member: current_user.actable, movie: @movie)
        
        if rating&.destroy
          render_success("Rating removed", :ok, { rated: false })
        else
          render_success("No rating found to remove", :ok, { rated: false })
        end
      end

      private

      def set_movie
        @movie = Movie.find_by(id: params[:id])
        return render_error("Movie not found", :not_found) if @movie.nil?
      end
    end
  end
end