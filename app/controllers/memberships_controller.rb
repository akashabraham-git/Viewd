class MembershipsController < ApplicationController
  def index
    @country = @current_user.country || "unknown"
    @tiers = MembershipTier.where(country: @country).where.not(name: "Free")
  end

  def update
    @tier = MembershipTier.find(params[:membership_tier_id])
    @membership = @current_user.actable.membership

    if @membership.update(
      membership_tier: @tier,
      status: :active,
      started_at: Time.current,
      expires_at: 1.month.from_now,
      transaction_id: rand(100000..999999)
    )
      redirect_to user_path(@current_user)
    else
      redirect_to memberships_path, alert: "Update failed."
    end
  end
end