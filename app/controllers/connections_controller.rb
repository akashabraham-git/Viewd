class ConnectionsController < ApplicationController
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
    @me = User.first
    @target_user = User.find(params[:following_id])

    unless Connection.exists?(follower_id: @me.id, following_id: @target_user.id) || @me == @target_user
      Connection.create(follower_id: @me.id, following_id: @target_user.id)
    end
    redirect_back fallback_location: user_path(@target_user)
  end

  def destroy
    @me = User.first
    relationship = Connection.find_by(follower_id: @me.id, following_id: params[:id])
    relationship&.destroy
    redirect_back fallback_location: user_path(params[:id])
  end
end