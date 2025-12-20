class RatingsController < ApplicationController
  def create
    @user = User.first 
    @movie = Movie.find(params[:movie_id])
    score = params[:rating].to_i

    if score.between?(1, 5)
      library = LibraryEntry.find_or_initialize_by(user: @user, movie: @movie)
      library.update(watched: true) unless library.watched

      rating_record = Rating.find_or_initialize_by(user: @user, movie: @movie)
      rating_record.update(rating: score) 
    end

    redirect_back fallback_location: movie_path(@movie)
  end
end