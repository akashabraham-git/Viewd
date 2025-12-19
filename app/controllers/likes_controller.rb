class LikesController < ApplicationController
  def toggle_movie_like
    @movie = Movie.find(params[:movie_id])
    @user = User.first
    like = Like.find_by(likeable: @movie, user: @user)
    if like 
      like.destroy
    else
      Like.create(likeable: @movie, user: @user)
      entry = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)
      if entry.watched == false
        entry.update(watched: true)
      end
    end
    redirect_back fallback_location: movie_path(@movie)
  end
end
