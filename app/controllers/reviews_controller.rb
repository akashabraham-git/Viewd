class ReviewsController < ApplicationController
  def create
    @movie = Movie.find(params[:movie_id])
    content = params[:review][:content]
    
    @review = @movie.reviews.build(content: content)
    @review.user = User.first

    if @review.save
      entry = LibraryEntry.find_or_initialize_by(user: @review.user, movie: @movie)
      entry.update(watched: true, date: Date.today)
      redirect_to movie_path(@movie), notice: "Review posted!"
    else
      redirect_to movie_path(@movie), alert: "Content cannot be blank."
    end
  end

  def edit
    @review = Review.find(params[:id])
    @movie = @review.movie
  end

  def update
    @review = Review.find(params[:id])
    content = params[:review][:content]
    
    if @review.update(content: content)
      redirect_to user_path(User.first), notice: "Review updated!"
    else
      @movie = @review.movie
      render :edit
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_back fallback_location: user_path(User.first)
  end
end