class ConnectionsController < ApplicationController
  before_action :set_me, except: :index
  before_action :authenticate_user!
  
  def index
    @user = User.find(params[:user_id])
    @type = params[:type]
    
    if @type == "following"
      @users = @user.actable.following
    else
      if @type == "followers"
        @users = @user.actable.followers
      else
        redirect_to user_path(@user), alert: "Invalid operation"
      end
    end
  end

  def create
    @target_user = User.find(params[:following_id])

    Connection.find_or_create_by(follower: @me.actable, following: @target_user.actable)
    redirect_back fallback_location: user_path(@target_user)
  end

  def destroy
    target_user = User.find_by(id: params[:id])
    target_member = target_user&.actable

    @connection = Connection.find_by(
      follower: @me.actable, 
      following: target_member
    )

    if @connection&.destroy
      flash[:notice] = "Unfollowed successfully."
    else
      flash[:alert] = "Could not find connection to remove."
    end
    redirect_back fallback_location: user_path(params[:id])
  end

  def set_me
    @me = @current_user
  end
end