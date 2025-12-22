class UsersController < ApplicationController
  before_action :set_user
  before_action :set_current_user, only: [:update, :destroy, :show] 

  def show
    @films_count = @user.library_entries.where.not(watched_date: nil).count
    @this_year_count = @user.library_entries.where('watched_date >= ?', Date.today.beginning_of_year).count
    @favorite_movies = Movie.joins(:likes)
                          .where(likes: { user_id: @user.id })
                          .order('likes.created_at DESC')
                          .limit(4)
    @watchlist = @user.library_entries.where(in_watchlist: true).order(updated_at: :desc).limit(5)
    @recent_activity = @user.library_entries.where.not(watched_date: nil).order(watched_date: :desc).limit(4)
    
    @all_movies = Movie.order(:title)
    @top_reviews = @user.reviews
                   .left_joins(:likes)
                   .group('reviews.id')
                   .order('COUNT(likes.id) DESC')
                   .limit(3)
                   .includes(:movie)
  end

  def edit
  end

  def update
      unless @user == @current_user
        redirect_to root_path, alert: "Unauthorized access"
        return
      end
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render :edit, alert: "#{@user.errors.full_messages.to_sentence}"

    end
  end

  def destroy
    return redirect_to root_path, alert: "Unauthorized" unless @user == @current_user

    @user.destroy
    redirect_to root_path
  end

  def watchlist
    @entries = @user.library_entries.where(in_watchlist: true).includes(:movie).order(updated_at: :desc)
  end

  def likes
    @liked_movies = Movie.joins(:likes).where(likes: { user_id: @user.id }).order('likes.created_at DESC')
  end

  def library
    @entries = @user.library_entries.where.not(watched_date: nil).includes(:movie).order(watched_date: :desc)
  end

  def reviews
    @current_user = User.second
    @reviews = @user.reviews.includes(:movie).order(created_at: :desc)
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil?
      redirect_to root_path, alert: "Invalid user"
    end
  end

  def set_current_user
    @current_user = User.second
  end
  
  def user_params
    params.require(:user).permit(:name, :bio, :profile_picture, :username, :email)
  end
  
end
