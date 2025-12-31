class MembersController < ApplicationController
  before_action :set_member

  def watchlist
    if @current_user&.actable_type == 'Member'
      @entries = @current_user.actable.library_entries.where(in_watchlist: true).includes(:movie).order(updated_at: :desc)
    else
      redirect_to user_path(@member.user), alert: "Watchlist is only available for members."
    end
  end

  def likes
    if @current_user&.actable_type == 'Member'
      @liked_movies = Movie.joins(:likes).where(likes: { member_id: @current_user.actable_id }).order('likes.created_at DESC')
    else
      redirect_to user_path(@member.user), alert: "Likes are only available for members."
    end
  end

  def library
    if @current_user&.actable_type == 'Member'
      @entries = @current_user.actable.library_entries.where.not(watched_date: nil).includes(:movie).order(watched_date: :desc)
    else
      redirect_to user_path(@member.user), alert: "Library is only available for members."
    end
  end

  def reviews
    if @current_user&.actable_type == 'Member'
      @reviews = @current_user.actable.reviews.includes(:movie).order(created_at: :desc)
    else
      redirect_to user_path(@member.user), alert: "Reviews are only available for members."
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
