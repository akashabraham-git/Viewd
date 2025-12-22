class MembershipsController < ApplicationController
  before_action :set_user
  def index
    @country = @user.country || "usa"
    @tiers = MembershipTier.where(country: @country).where.not(name: "Free")
  end

  def update
    @tier = MembershipTier.find(params[:membership_tier_id])
    @membership = @user.membership

    if @membership.update(
      membership_tier: @tier,
      status: :active,
      started_at: Time.current,
      expires_at: 1.month.from_now,
      transaction_id: rand(100000..999999)
    )
      redirect_to user_path(@user)
    else
      redirect_to memberships_path, alert: "Update failed."
    end
  end

  def set_user
    @user = User.second
  end

end