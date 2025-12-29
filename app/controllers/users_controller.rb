class UsersController < ApplicationController
  before_action :set_user
  before_action :set_current_user

  def show
    if @user.actable_type == 'Member'
      member = @user.actable
      
      @films_count = member.library_entries.where.not(watched_date: nil).count
      @this_year_count = member.library_entries.where('watched_date >= ?', Date.today.beginning_of_year).count
      
      @favorite_movies = Movie.joins(:likes)
                            .where(likes: { member_id: member.id }) 
                            .order('likes.created_at DESC')
                            .limit(4)

      @watchlist = member.library_entries.where(in_watchlist: true).order(updated_at: :desc).limit(5)
      @recent_activity = member.library_entries.where.not(watched_date: nil).order(watched_date: :desc).limit(4)
      
      @top_reviews = member.reviews
                   .left_joins(:likes)
                   .group('reviews.id')
                   .order('COUNT(likes.id) DESC')
                   .limit(3)
                   .includes(:movie)
    elsif @user.actable_type == 'Moderator'
      @managed_movies = @user.actable.managed_movies.limit(10)
    end

    @all_movies = Movie.order(:title)
  end

  def edit
    redirect_to root_path, alert: "Unauthorized" unless @user == @current_user
  end

  def update
    unless @user == @current_user
      redirect_to root_path, alert: "Unauthorized access"
      return
    end

    if @user.update(user_params)
      if @user.actable_type == "Member" && params[:user][:profile_picture].present?
        @user.actable.profile_picture.attach(params[:user][:profile_picture])
      end
      
      redirect_to user_path(@user), notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return redirect_to root_path, alert: "Unauthorized" unless @user == @current_user

    if @user.destroy
      redirect_to root_path, notice: "Account deleted."
    else
      redirect_back fallback_location: user_path(@user), alert: @user.errors.full_messages.to_sentence
    end
  end

  def watchlist
    if @user.actable_type == 'Member'
      @entries = @user.actable.library_entries.where(in_watchlist: true).includes(:movie).order(updated_at: :desc)
    else
      redirect_to user_path(@user), alert: "Watchlist is only available for members."
    end
  end

  def likes
    if @user.actable_type == 'Member'
      @liked_movies = Movie.joins(:likes).where(likes: { member_id: @user.actable_id }).order('likes.created_at DESC')
    else
      redirect_to user_path(@user), alert: "Likes are only available for members."
    end
  end

  def library
    if @user.actable_type == 'Member'
      @entries = @user.actable.library_entries.where.not(watched_date: nil).includes(:movie).order(watched_date: :desc)
    else
      redirect_to user_path(@user), alert: "Library is only available for members."
    end
  end

  def reviews
    if @user.actable_type == 'Member'
      @reviews = @user.actable.reviews.includes(:movie).order(created_at: :desc)
    else
      redirect_to user_path(@user), alert: "Reviews are only available for members."
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil?
      redirect_to root_path, alert: "Invalid user"
    end
  end

  def set_current_user
    @current_user = User.find(13)
  end
  
  def user_params
    params.require(:user).permit(:name, :bio, :profile_picture, :username, :email)
  end
end