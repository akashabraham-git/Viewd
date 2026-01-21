module Api
  module V1
    class MoviesController < BaseController
      skip_before_action :doorkeeper_authorize!, only: [:show, :index]
      before_action :set_movie, only: [:show, :update, :destroy]
      before_action :authorize_moderator!, only: [:create, :update, :destroy]

      def index
        movies = Movie.order(created_at: :desc)

        @pagy, @movies = pagy(
          movies,
          page: params[:page],
          limit: params[:per_page]
        )

        render 'index'
      end


      def show
        render 'show'
      end

      def create
        @movie = Movie.new(movie_params)
        if @movie.save
          render 'show', status: :created
        else
          render_error(@movie.errors.full_messages.to_sentence, :unprocessable_content)
        end
      end

      def update
        if @movie.update(movie_params)
          render 'show', status: :ok
        else
          render_error(@movie.errors.full_messages.to_sentence, :unprocessable_content)
        end
      end

      def destroy
        if @movie.destroy
          render_success("Movie deleted", :ok)
        else
          render_error(@movie.errors.full_messages.to_sentence)
        end
      end

      def discover
        @movies = Movie.released

        case params[:mode]
        when 'new'
          @movies = @movies.recent
        when 'top'
          @movies = @movies.joins(:ratings)
                          .group(:id)
                          .order('AVG(ratings.rating) DESC')
        end

     
        render json: @movies.limit(20)
      end

      def recommend
        if current_user&.actable_type == 'Member'
          @movies = Movie.recommended_for(current_user.actable).limit(10)
        else
          @movies = Movie.released.recent.limit(10)
        end

        render json: @movies
      end

      private

      def set_movie
        @movie = Movie.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Movie not found", :not_found)
      end

      def movie_params
        params.require(:movie).permit(:title, :synopsis, :release_date, :poster_url, :tmdb_id, :language, :runtime, :status, :origin_country)
      end
    end
  end
end