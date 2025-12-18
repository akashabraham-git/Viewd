class RatingsController < ApplicationController
  def create_or_update
    @user = User.first 
    @movie = Movie.find(params[:movie_id])
    score = params[:score].to_i

    library = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)
    library.update(watched: true)

    rating = Rating.find_or_initialize_by(user: @user, movie: @movie)
    rating.update(rating: score)

    redirect_back fallback_location: movie_path(@movie), notice: "Rated #{score} stars!"
  end
end
