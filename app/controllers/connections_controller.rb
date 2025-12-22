class ConnectionsController < ApplicationController
  before_action :set_me, except: :index

  def index
    @user = User.find(params[:user_id])
    @type = params[:type]
    
    if @type == "following"
      @users = @user.following
    else
      @users = @user.followers
    end
  end

  def create
    @target_user = User.find(params[:following_id])

    Connection.find_or_create_by(follower: @me, following: @target_user)
    redirect_back fallback_location: user_path(@target_user)
  end

  def destroy
    relationship = Connection.find_by(follower_id: @me.id, following_id: params[:id])
    relationship&.destroy
    redirect_back fallback_location: user_path(params[:id])
  end

  def set_me
    @me = User.second
  end
end