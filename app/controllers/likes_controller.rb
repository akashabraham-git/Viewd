class LikesController < ApplicationController
  before_action :set_movie

  def toggle_movie_like
    if @current_user.nil?
      redirect_back fallback_location: movies_path, alert: "sign in for liking"
      return
    end
    
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

    if @current_user.nil?
      redirect_back fallback_location: movie_path(@movie), alert: "sign in for liking"
      return
    end
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

    if @movie.nil? && params[:id].present?
    @movie = Movie.find_by(id: params[:id])
    
    if @movie.nil?
      @movie = Review.find_by(id: params[:id])&.movie
    end
  end

    if @movie.nil?
      redirect_to movies_path, alert: "Error: Movie not found."
    end
  end


end