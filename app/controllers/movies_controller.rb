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
    @popular_reviews = @movie.reviews
                              .left_joins(:likes)
                              .group(:id)
                              .order('COUNT(likes.id) DESC, reviews.created_at DESC')
                              .limit(3)
                              .includes(user: { profile_picture_attachment: :blob })
    @credits = @movie.credits.includes(:cast)
    @actors = @credits.where(job: 'Actor')
    @crew_groups = @credits.where.not(job: 'Actor').group_by(&:job)
    @genres = @movie.genres
    @total_watch = @movie.library_entries.where.not(watched_date: nil).count
    @total_likes = @movie.likes.count
    @user = User.second
    @library_entry = @user.library_entries&.find_by(movie: @movie)
  end
end