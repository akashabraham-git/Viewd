module Api
  module V1
    class MoviesController < ActionController::API
      include Pagy::Backend
      
      before_action :set_movie, only: [:show, :update, :destroy]

      def index
        movies = Movie.order(created_at: :desc)

        pagy, records = pagy(
          movies,
          page: params[:page],
          limit: params[:per_page]
        )

        render json: {
          movies: records,
          meta: {
            current_page: pagy.page,
            next_page: pagy.next,
            prev_page: pagy.prev,
            total_pages: pagy.pages,
            total_count: pagy.count,
            is_first_page: pagy.page == 1,
            is_last_page: pagy.page == pagy.pages
          }
        }, status: :ok
      end


      def show
        render json: @movie, status: :ok
      end

      def create
        @movie = Movie.new(movie_params)
        if @movie.save
          render json: @movie, status: :created
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @movie.update(movie_params)
          render json: @movie, status: :ok
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @movie.destroy
        head :no_content
      end

      private

      def set_movie
        @movie = Movie.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Movie not found" }, status: :not_found
      end

      def movie_params
        params.require(:movie).permit(:title, :synopsis, :release_date, :poster_url, :tmdb_id)
      end
    end
  end
end