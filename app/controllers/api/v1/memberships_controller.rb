module Api
  module V1
    class MembershipsController < BaseController
      before_action :check_member_type
      skip_before_action :doorkeeper_authorize!, only: :index

      def index
        @country = current_user.country || "unknown"
        @tiers = MembershipTier.where(country: @country).where.not(name: "Free")
        render 'api/v1/memberships/index'
      end

      def show
        @membership = current_user.actable.membership
        render 'show'
      end

      def update
        @tier = MembershipTier.find_by(id: params[:membership_tier_id])
        return render_error("Membership tier not found", :not_found) if @tier.nil?

        @membership = current_user.actable.membership

        if @membership.update(
          membership_tier: @tier,
          status: :active,
          started_at: Time.current,
          expires_at: 1.month.from_now,
          transaction_id: rand(100000..999999)
        )
          render 'api/v1/memberships/show', status: :ok
        else
          render_error(@membership.errors.full_messages.to_sentence)
        end
      end

      private

      def check_member_type
        unless current_user&.actable_type == 'Member'
          render_error("Only members can manage memberships", :forbidden)
        end
      end
    end
  end
end