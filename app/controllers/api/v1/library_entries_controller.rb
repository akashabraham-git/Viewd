module Api
  module V1
    class LibraryEntriesController < BaseController
      before_action :set_movie

      def toggle_watched
        entry = LibraryEntry.find_or_initialize_by(member: current_user.actable, movie: @movie)

        if entry.watched_date.nil?
          entry.watched_date = Date.today
          entry.in_watchlist = false
          entry.save
          render json: { 
            message: "Added to watched films", 
            watched: true,
            watched_date: entry.watched_date 
          }, status: :ok
        else
          has_rating = Rating.exists?(member: current_user.actable, movie: @movie)
          has_review = Review.exists?(member: current_user.actable, movie: @movie)

          if has_rating || has_review
            render_error("Can't be removed from your films since there's an activity in it", :unprocessable_entity)
          else
            entry.update(watched_date: nil)
            render json: { 
              message: "Removed from watched films", 
              watched: false 
            }, status: :ok
          end
        end
      end

      def toggle_watchlist
        entry = LibraryEntry.find_or_initialize_by(member: current_user.actable, movie: @movie)
        entry.in_watchlist = !entry.in_watchlist
        entry.save
        
        render json: { 
          message: entry.in_watchlist ? "Added to watchlist" : "Removed from watchlist",
          in_watchlist: entry.in_watchlist 
        }, status: :ok
      end

      private

      def set_movie
        @movie = Movie.find_by(id: params[:id])
        return render_error("Movie not found", :not_found) if @movie.nil?
      end
    end
  end
end