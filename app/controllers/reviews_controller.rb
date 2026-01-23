class ReviewsController < ApplicationController
  before_action :set_movie 
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  def index
    @reviews = @movie.reviews
                     .left_joins(:likes)
                     .group(:id)
                     .order('COUNT(likes.id) DESC, reviews.created_at DESC')
                     .includes(member: { profile_picture_attachment: :blob })
  end

  def show
    @review = Review.includes(:movie, :member).find(params[:id])
    @rating = Rating.find_by(member: @review.member, movie: @review.movie)&.rating
    session[:review_return_to] = request.referer
  end

  def create
    @review = Review.new(review_params.merge(movie: @movie, member: @current_user.actable))
    @review.current_user_instance = current_user
    if @review.save
      redirect_to movie_path(@movie)
    else
      redirect_to movie_path(@movie), alert: @review.errors.full_messages.to_sentence
    end
  end

  def edit
    session[:review_return_to] = request.referer
  end

  def update
    if @review.update(review_params)
      return_path = session.delete(:review_return_to) 
      redirect_to return_path
    else
      redirect_back fallback_location: edit_review_path(@review), alert: "#{@review.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    return_path = request.referer 
    deleted_review_url = review_path(@review)

    if @review.destroy_fully!
      if return_path.include?(deleted_review_url)
        return_path = session.delete(:review_return_to) 
        redirect_to return_path, notice: "Review deleted."
      else
        redirect_to return_path, notice: "Review deleted."
      end
    else
      redirect_back fallback_location: movie_path(@movie), alert: "Could not delete review."
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def set_review
    @review = Review.find(params[:id])
    @movie = @review.movie
  end

  def review_params
    params.require(:review).permit(:content)
  end
end