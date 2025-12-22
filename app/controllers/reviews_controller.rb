class ReviewsController < ApplicationController
  before_action :set_movie, only: [:index, :create]
  before_action :set_review, only: [:edit, :update, :destroy]
  before_action :set_current_user, only: [:index, :show]

  def index
    @reviews = @movie.reviews
                     .left_joins(:likes)
                     .group(:id)
                     .order('COUNT(likes.id) DESC, reviews.created_at DESC')
                     .includes(user: { profile_picture_attachment: :blob })
  end

  def show
    @review = Review.includes(:movie, :user).find(params[:id])
    @rating = Rating.find_by(user: @review.user, movie: @review.movie).rating
  end

  def create
    @review = @movie.reviews.build(review_params)
    @review.user = User.second

    if @review.save
      redirect_to movie_path(@movie)
    else
      redirect_to movie_path(@movie), alert: @review.errors.full_messages.to_sentence
    end
  end

  def edit
    @movie = @review.movie
    session[:review_return_to] = request.referer
  end

  def update
    if @review.update(review_params)
      return_path = session.delete(:review_return_to) 
      redirect_to return_path
    else
      render :edit, alert: "#{@user.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @review.destroy
    redirect_back fallback_location: root_path
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def set_current_user
    @current_user = User.second
  end

  def review_params
    params.require(:review).permit(:content)
  end
end