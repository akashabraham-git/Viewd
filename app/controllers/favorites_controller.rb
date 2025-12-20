class FavoritesController < ApplicationController


  def create
    @user = User.first
    movie = Movie.find_by(id: params[:movie_id])

    if movie && @user.favorites.count < 4
      entry = LibraryEntry.find_or_initialize_by(user: @user, movie: movie)
      entry.update(watched: true, date: Date.today) unless entry.watched?
      
      Favorite.find_or_create_by(user: @user, movie: movie)
    end
    redirect_to user_path(@user, edit_favorites: true)
  end

    redirect_to user_path(@user, edit_favorites: true)
  end

  def destroy
    @user = User.first
    favorite = @user.favorites.find_by(movie_id: params[:id])
    favorite&.destroy
    
    redirect_to user_path(@user, edit_favorites: true)
  end

end