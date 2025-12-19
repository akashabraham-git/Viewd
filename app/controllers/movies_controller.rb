class MoviesController < ApplicationController
  def index
    if params[:query].present?
      @movies = Movie.where("title ILIKE ?", "%#{params[:query]}%")
    else
      @movies = Movie.all
    end
  end

  def show
    @movie = Movie.find_by(id: params[:id])
    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
      return
    end
    @credits = @movie.credits.includes(:cast)
    @total_watch = @movie.library_entries.where(watched: true).count
    @total_likes = @movie.likes.count
    @user = User.first
    @library_entry = @user.library_entries&.find_by(movie: @movie)
  end
end