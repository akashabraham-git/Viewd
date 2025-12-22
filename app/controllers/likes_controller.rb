class LikesController < ApplicationController
  before_action :set_movie
  before_action :set_user

  def toggle_movie_like
    like = Like.find_by(likeable: @movie, user: @user)
    if like 
      like.destroy
    else
      Like.create(likeable: @movie, user: @user)
    end
    redirect_back fallback_location: movie_path(@movie)
  end
  
  def toggle_review_like
    @review = Review.find(params[:id])
    @like = @review.likes.find_by(user: @user)

    if @like
      @like.destroy
    else
      @review.likes.create(user: @user)
    end

    redirect_back fallback_location: root_path
  end

  private

  def set_movie
    @movie = Movie.find_by(id: params[:movie_id])
    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
    end
  end

  def set_user
    @user = User.second
    if @user.nil?
      redirect_to movies_path, alert: "Please log in to enter activity"
    end
  end

end
