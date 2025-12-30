class MembersController < ApplicationController
  before_action :set_member

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

  def set_member
    @member = Member.find_by(id: params[:id])
    if @member.nil?
      redirect_to root_path, alert: "Invalid user"
    end
  end
end
