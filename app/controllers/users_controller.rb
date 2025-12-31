class UsersController < ApplicationController
  before_action :set_user

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
    end

    @all_movies = Movie.order(:title)
  end

  def edit
    @user.build_actable if @user.actable.nil? && @user.actable_type == 'Member'
    redirect_to root_path, alert: "Unauthorized" unless @user == @current_user
  end

  def update
    unless @user == @current_user
      redirect_to root_path, alert: "Unauthorized access"
      return
    end

    if @user.update(user_params)

      
      redirect_to user_path(@user), notice: "Profile updated successfully."
    else
      flash.now[:alert] =  @user.errors.full_messages.to_sentence
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

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil?
      redirect_to root_path, alert: "Invalid user"
    end
  end

  
  def user_params
    params.require(:user).permit(
      :name, :email, :username,
      actable_attributes: [:id, :bio, :profile_picture]
    )
  end
end