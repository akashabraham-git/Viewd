class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authorize_moderator!, except: [:index, :show]

  def index
    @query = params[:query]
    @type = params[:type] || "movies" 

    if @query.present?
      case @type
      when "users"
        @results = User.where("username ILIKE ?", "%#{@query}%")
      when "cast"
        @results = Cast.where("name ILIKE ?", "%#{@query}%")
      when "genres"
        @results = Genre.where("name ILIKE ?", "%#{@query}%")
      else
        @results = Movie.where("title ILIKE ?", "%#{@query}%")
      end
    else
      @results = Movie.all
    end
  end

  def show
    if @movie.nil?
      return redirect_to movies_path, alert: "Error: Movie not found."
    end

    @popular_reviews = @movie.reviews
                              .left_joins(:likes)
                              .group(:id)
                              .order('COUNT(likes.id) DESC, reviews.created_at DESC')
                              .limit(3)
                              .includes(member: [:user, { profile_picture_attachment: :blob }])

    @credits = @movie.credits.includes(:cast)
    @actors = @credits.where(job: 'Actor')
    @crew_groups = @credits.where.not(job: 'Actor').group_by(&:job)
    @genres = @movie.genres
    @total_watch = @movie.library_entries.where.not(watched_date: nil).count
    @total_likes = @movie.likes.count

    if @current_user&.actable_type == 'Member'
      @review = @movie.reviews.build
      @library_entry = @current_user.actable.library_entries.find_by(movie: @movie)
    end
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to @movie, notice: "Movie created successfully."
    else
      flash.now[:alert] =  @movie.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end
  
  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Movie was successfully updated."
    else
      flash.now[:alert] =  @movie.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_path, notice: "Movie was successfully removed."
  end

  private

  def set_movie
    @movie = Movie.find_by(id: params[:id])
  end

  def movie_params
    params.require(:movie).permit(
      :title, :synopsis, :poster_url, :release_date, :origin_country, :runtime, :language,
      genre_ids: [], 
      credits_attributes: [:id, :cast_id, :character, :job, :_destroy]
    )
  end
end