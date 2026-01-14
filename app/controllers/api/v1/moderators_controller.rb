module Api
  module V1
    class ModeratorsController < BaseController
      before_action :authorize_moderator!
      before_action :set_moderator, only: [:show, :update, :destroy]

      def show
        render 'show'
      end

      def update
        if @moderator.update(moderator_params)
          render 'show', status: :ok
        else
          render_error(@moderator.errors.full_messages.to_sentence)
        end
      end

      def destroy
        @moderator.destroy
        render_success("Moderator account removed", :ok)
      end

      private

      def set_moderator
        @moderator = Moderator.find_by(id: params[:id])
        return render_error("Moderator not found", :not_found) if @moderator.nil?
      end

      def moderator_params
        params.require(:moderator).permit(
          :employee_number, :department,
          user_attributes: [:id, :name, :email, :username, :password, :password_confirmation]
        )
      end
    end
  end
end