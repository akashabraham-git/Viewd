class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authorize_moderator!, except: [:index, :show]

  def index
    @current_user = User.find(13)
    @query = params[:query]
    @type = params[:type] || "movies" 

    if @query.present?
      case @type
      when "users"
        @results = User.where("username ILIKE ?", "%#{@query}%")
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
    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
      return
    end

    @popular_reviews = @movie.reviews
                              .left_joins(:likes)
                              .group(:id)
                              .order('COUNT(likes.id) DESC, reviews.created_at DESC')
                              .limit(3)
                              .includes(member: { profile_picture_attachment: :blob })

    @credits = @movie.credits.includes(:cast)
    @actors = @credits.where(job: 'Actor')
    @crew_groups = @credits.where.not(job: 'Actor').group_by(&:job)
    @genres = @movie.genres

    @total_watch = @movie.library_entries.where.not(watched_date: nil).count
    @total_likes = @movie.likes.count

    @user = User.find(13) 
    if @user.actable_type == 'Member'
      @library_entry = @user.actable.library_entries.find_by(movie: @movie)
    else
      @library_entry = nil
    end
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    
    if @current_user&.actable_type == "Moderator"
      @movie.moderator = @current_user.actable 
    end

    if @movie.save
      redirect_to @movie, notice: "Movie created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end
  
  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Movie was successfully updated."
    else
      redirect_back fallback_location: edit_movie_path(@movie), alert: "#{@movie.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_path, notice: "Movie was successfully removed."
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:title, :synopsis, :release_date, :poster_url, :runtime, :language, :origin_country)
  end
end