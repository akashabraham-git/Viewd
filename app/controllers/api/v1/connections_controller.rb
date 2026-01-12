# app/controllers/api/v1/connections_controller.rb
module Api
  module V1
    class ConnectionsController < BaseController
      before_action :set_me, except: :index

      # GET /api/v1/users/:user_id/connections
      def index
        @user = User.find_by(id: params[:user_id])
        return render_error("User not found", :not_found) if @user.nil?

        @type = params[:type]

        if @type == "following"
          @users = @user.actable.following
        elsif @type == "followers"
          @users = @user.actable.followers
        else
          return render_error("Invalid operation. Type must be 'following' or 'followers'", :bad_request)
        end

        render 'api/v1/connections/index'
      end

      def create
        @target_user = User.find_by(id: params[:following_id])
        return render_error("User not found", :not_found) if @target_user.nil?

        @connection = Connection.find_or_create_by(follower: @me.actable, following: @target_user.actable)
        
        render json: { 
          message: "Followed successfully",
          following: true,
          connection_id: @connection.id 
        }, status: :created
      end

      def destroy
        target_user = User.find_by(id: params[:id])
        return render_error("User not found", :not_found) if target_user.nil?

        target_member = target_user&.actable

        @connection = Connection.find_by(
          follower: @me.actable,
          following: target_member
        )

        if @connection&.destroy
          render_success("Unfollowed successfully", :ok, { following: false })
        else
          render_error("Could not find connection to remove", :not_found)
        end
      end

      private

      def set_me
        @me = current_user
      end
    end
  end
end