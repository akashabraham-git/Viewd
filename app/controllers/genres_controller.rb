class GenresController < ApplicationController
  before_action :authorize_moderator!, except: [:show]
  before_action :set_genre, only: [:show, :edit, :update, :destroy]

  def index
    @genres = Genre.order(:name)
  end

  def show
    @movies = @genre.movies.order(release_date: :desc)
  end

  def new
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(genre_params)
    if @genre.save
      redirect_to genres_path, notice: "Genre created successfully."
    else
      flash.now[:alert] =  @genre.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @genre.update(genre_params)
      redirect_to genres_path, notice: "Genre updated successfully."
    else
      flash.now[:alert] =  @genre.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @genre.destroy
    redirect_to genres_path, notice: "Genre deleted."
  end

  private

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end