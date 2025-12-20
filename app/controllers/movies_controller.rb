class MoviesController < ApplicationController
  def index
    @query = params[:query]
    @type = params[:type] || "movies" 

    if @query.present?
      case @type
      when "users"
        @results = User.where("name ILIKE ?", "%#{@query}%")
      when "cast"
        @results = Cast.where("name ILIKE ?", "%#{@query}%")
      else
        @results = Movie.where("title ILIKE ?", "%#{@query}%")
      end
    else
      @results = Movie.all.limit(20)
    end
  end

  def show
    @movie = Movie.find_by(id: params[:id])
    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
      return
    end
    @movie = Movie.find(params[:id])
    @popular_reviews = @movie.reviews.includes(:user).order(created_at: :desc).limit(3)
    @new_review = Review.new
    @credits = @movie.credits.includes(:cast)
    #@cast = @credits.cast
    @total_watch = @movie.library_entries.where(watched: true).count
    @total_likes = @movie.likes.count
    @user = User.first
    @library_entry = @user.library_entries&.find_by(movie: @movie)
  end
end