module Api
  module V1
    class BaseController < ActionController::API
      include Pagy::Backend
      before_action :doorkeeper_authorize!
      helper_method :pagy_metadata
      respond_to :json

      private

      def authenticate_user_from_session!
        unless current_user
          render json: { error: "Authentication required" }, status: :unauthorized
        end
      end

      def current_resource_owner
        @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def current_user
        current_resource_owner
      end

      def authorize_moderator!
        unless current_user&.actable_type == 'Moderator'
          render json: { error: "Only moderators can do that." }, status: :forbidden
        end
      end

      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end

      def render_success(message, status = :ok, data = {})
        render json: { message: message }.merge(data), status: status
      end
  
    end
  end
end