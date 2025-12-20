class LibraryEntriesController < ApplicationController
  before_action :set_movie

  def library
    @user = User.find(params[:id])
    @entries = @user.library_entries.where(watched: true).includes(:movie)
  end

  def watchlist
    @user = User.find(params[:id])
    @entries = @user.library_entries.where(watchlist: true).includes(:movie)
  end

  def toggle_watched
    entry = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)
    entry.watched = !entry.watched
    if entry.watched
      entry.date = Date.today
    else
      like = Like.find_by(likeable: @movie, user: @user) 
      like.destroy if like
      rating = Rating.find_by(user: @user, movie: @movie)
      rating.destroy if rating
    end
    entry.save
    redirect_back fallback_location: movie_path(@movie)
  end

  def toggle_watchlist
    entry = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)
    entry.watchlist = !entry.watchlist
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

end