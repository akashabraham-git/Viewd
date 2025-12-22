class LibraryEntriesController < ApplicationController
  before_action :set_movie
  before_action :set_user

  def toggle_watched
    entry = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)

    if entry.watched_date.nil?
      entry.watched_date = Date.today
      entry.in_watchlist = false 
      entry.save
      redirect_back fallback_location: movie_path(@movie)
    else
      has_rating = Rating.exists?(user: @user, movie: @movie)
      has_review = Review.exists?(user: @user, movie: @movie)

      if has_rating || has_review
        redirect_back fallback_location: movie_path(@movie), alert: "Can't be removed from your films since there's an activity in it."
      else
        entry.update(watched_date: nil)
        redirect_back fallback_location: movie_path(@movie)
      end
    end
  end

  def toggle_watchlist
    entry = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)
    entry.in_watchlist = !entry.in_watchlist
    entry.save
    redirect_back fallback_location: movie_path(@movie)
  end

  private

  def set_movie
    @movie = Movie.find_by(id: params[:movie_id])
    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
    end
  end

  def set_user
    @user = User.second
    if @user.nil?
      redirect_to movies_path, alert: "Please log in to enter activity"
    end
  end

end