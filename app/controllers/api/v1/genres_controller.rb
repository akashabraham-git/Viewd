module Api
  module V1
    class GenresController < BaseController
      skip_before_action :doorkeeper_authorize!, only: [:show, :index]
      before_action :authorize_moderator!, except: [:show, :index]
      before_action :set_genre, only: [:show, :update, :destroy]

      def index
        @genres = Genre.order(:name)
        render 'api/v1/genres/index'
      end

      def show
        @movies = @genre.movies.order(release_date: :desc)
        render 'api/v1/genres/show'
      end

      def create
        @genre = Genre.new(genre_params)
        
        if @genre.save
          render 'api/v1/genres/show', status: :created
        else
          render_error(@genre.errors.full_messages.to_sentence)
        end
      end

      def update
        if @genre.update(genre_params)
          render 'api/v1/genres/show', status: :ok
        else
          render_error(@genre.errors.full_messages.to_sentence)
        end
      end

      def destroy
        @genre.destroy
        render_success("Genre deleted", :ok)
      end

      private

      def set_genre
        @genre = Genre.find_by(id: params[:id])
        return render_error("Genre not found", :not_found) if @genre.nil?
      end

      def genre_params
        params.require(:genre).permit(:name)
      end
    end
  end
end