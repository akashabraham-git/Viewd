class RatingsController < ApplicationController
  def toggle
    @user = User.second
    @movie = Movie.find(params[:movie_id])
    score = params[:rating].to_i 

    existing_rating = Rating.find_by(user: @user, movie: @movie)

    if existing_rating && (score == 0 || existing_rating.rating == score)
      existing_rating.destroy
    else
      rating_record = Rating.find_or_initialize_by(user: @user, movie: @movie)
      rating_record.update(rating: score)
    end

    redirect_back fallback_location: movie_path(@movie)
  end

end