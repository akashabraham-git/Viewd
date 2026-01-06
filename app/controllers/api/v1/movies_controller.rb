module Api
  module V1
    class MoviesController < ActionController::API
      def index
        @movies = Movie.all
        render json: @movies
      end

      def show
        @movie = Movie.find(params[:id])
        render json: @movie.as_json
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Movie not found" }, status: :not_found
      end
    end
  end
end