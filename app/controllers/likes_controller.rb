class LikesController < ApplicationController
  before_action :set_movie

  def toggle_movie_like
    like = @movie.likes.find_by(member: @current_user.actable)

    if like 
      like.destroy
    else
      @movie.likes.create!(member: @current_user.actable)
    end
    
    redirect_back fallback_location: movie_path(@movie)
  end
  
  def toggle_review_like
    @review = Review.find(params[:id])

    redirect_back fallback_location: movie_path(@movie), alert: "sign in for liking" unless @current_user 
    return
    @like = @review.likes.find_by(member: @current_user&.actable)

    if @like
      @like.destroy
    else
      @review.likes.create(member: @current_user&.actable)
    end

    redirect_back fallback_location: movie_path(@movie)
  end

  private

  def set_movie
    movie_id = params[:movie_id] || params[:id]
    @movie = Movie.find_by(id: movie_id)

    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
    end
  end


end