
module Api
  module V1
    class MembersController < BaseController
      before_action :set_member
      before_action :check_member_type

      def watchlist
        @entries = current_user.actable.library_entries
                              .where(in_watchlist: true)
                              .includes(:movie)
                              .order(updated_at: :desc)
        
        render 'api/v1/members/watchlist'
      end

      def likes
        @liked_movies = Movie.joins(:likes)
                            .where(likes: { member_id: current_user.actable_id })
                            .order('likes.created_at DESC')
        
        render 'api/v1/members/likes'
      end

      def library
        @entries = current_user.actable.library_entries
                              .where.not(watched_date: nil)
                              .includes(:movie)
                              .order(watched_date: :desc)
        
        render 'api/v1/members/library'
      end

      def reviews
        @reviews = current_user.actable.reviews
                              .includes(:movie)
                              .order(created_at: :desc)
        
        render 'api/v1/members/reviews'
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
    end
  end
end