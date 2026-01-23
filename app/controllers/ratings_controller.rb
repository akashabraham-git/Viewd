class RatingsController < ApplicationController
  def toggle

    @movie = Movie.find(params[:id])
    score = params[:rating].to_i 

    existing_rating = Rating.find_by(member: @current_user.actable, movie: @movie)

    if existing_rating && (score == 0 || existing_rating.rating == score)
      existing_rating.destroy_fully!
    else
      rating_record = Rating.find_or_initialize_by(member: @current_user.actable, movie: @movie)
      rating_record.current_user_instance = current_user
      rating_record.update(rating: score)
    end

    redirect_back fallback_location: movie_path(@movie)
  end

end