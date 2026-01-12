module Api
  module V1
    class UsersController < BaseController
      skip_before_action :doorkeeper_authorize!, only: [:show]
      before_action :set_user
      before_action :check_authorization, only: [:update, :destroy]

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

        render 'api/v1/users/show'
      end

      def update
        if @user.update(user_params)
          render 'api/v1/users/show', status: :ok
        else
          render_error(@user.errors.full_messages.to_sentence)
        end
      end

      def destroy
        if @user.destroy
          render_success("Account deleted", :ok)
        else
          render_error(@user.errors.full_messages.to_sentence)
        end
      end

      private

      def set_user
        @user = User.find_by(id: params[:id])
        return render_error("User not found", :not_found) if @user.nil?
      end

      def check_authorization
        unless @user == current_user
          render_error("Unauthorized access", :forbidden)
        end
      end

      def user_params
        params.require(:user).permit(
          :name, :email, :username,
          actable_attributes: [:id, :bio, :profile_picture]
        )
      end
    end
  end
end