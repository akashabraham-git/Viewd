class UsersController < ApplicationController
  def show
    @user = User.find_by(id: params[:id]) || User.first
    
    @edit_mode = params[:edit_favorites] == "true"
    @me = User.first 
    @films_count = @user.library_entries.where(watched: true).count
    @this_year_count = @user.library_entries.where(watched: true).where('created_at >= ?', Date.today.beginning_of_year).count

    @favorites = @user.favorite_movies.limit(4)
    @watchlist = @user.library_entries.where(watchlist: true).order(created_at: :desc).limit(5)
    @recent_activity = @user.library_entries.where(watched: true).order(created_at: :desc).limit(4)
    
    @all_movies = Movie.order(:title)
  end
  def watchlist
    @user = User.find(params[:id])
    @entries = @user.library_entries
                    .where(watchlist: true)
                    .includes(:movie)
                    .order(created_at: :desc)
  end
end