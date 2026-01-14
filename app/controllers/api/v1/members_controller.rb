
module Api
  module V1
    class MembersController < BaseController
      before_action :set_member, except: :create
      before_action :check_member_type, except: :create
      skip_before_action :doorkeeper_authorize!, only: [:create, :show]

      def show
        render 'show'
      end

      def create
        @member = Member.new(member_params)
        if @member.save
          render 'show', status: :created
        else
          render_error(@member.errors.full_messages.to_sentence)
        end
      end

      def update
        if @member.update(member_params)
          render 'show', status: :ok
        else
          render_error(@member.errors.full_messages.to_sentence)
        end
      end

      def destroy
        @member.destroy
        render_success("Member deleted", :ok)
      end

      def watchlist
        @entries = current_user.actable.library_entries
                              .where(in_watchlist: true)
                              .includes(:movie)
                              .order(updated_at: :desc)
        
        render 'watchlist'
      end

      def likes
        @liked_movies = Movie.joins(:likes)
                            .where(likes: { member_id: current_user.actable_id })
                            .order('likes.created_at DESC')
        
        render 'likes'
      end

      def library
        @entries = current_user.actable.library_entries
                              .where.not(watched_date: nil)
                              .includes(:movie)
                              .order(watched_date: :desc)
        
        render 'library'
      end

      def reviews
        @reviews = current_user.actable.reviews
                              .includes(:movie)
                              .order(created_at: :desc)
        
        render 'reviews'
      end

      private

      def set_member
        @member = Member.find_by(id: params[:id])
        return render_error("Member not found", :not_found) if @member.nil?
      end

      def check_member_type
        unless current_user&.actable_type == 'Member'
          render_error("This resource is only available for members", :forbidden)
        end
      end

      def member_params
        params.require(:member).permit(
          :bio, :country,
          user_attributes: [:name, :email, :username, :password, :password_confirmation]
        )
      end
    end
  end
end