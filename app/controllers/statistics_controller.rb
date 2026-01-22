class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_member!
  before_action :check_pro_membership!
  before_action :fetch_available_years, only: [:index, :by_year]

  def index
    @all_time_stats = MemberStatisticsService.new(@current_member).call
  end

  def by_year
    year = params[:year].to_i
    validate_year!(year)

    @year_stats = MemberStatisticsService.new(@current_member, year).call
  end

  private

  def ensure_member!
    @current_member = current_user.actable
    unless @current_member.is_a?(Member)
      redirect_to root_path, alert: 'Statistics are only available for members.'
    end
  end

  def check_pro_membership!
    membership = @current_member.membership
    tier_name = membership&.membership_tier&.name
    unless tier_name&.in?(['Pro', 'Patron'])
      redirect_to memberships_path, alert: 'Upgrade to Pro or Patron to access statistics.'
    end
  end

  def validate_year!(year)
    current_year = Date.today.year
    if year < 2000 || year > current_year
      redirect_to statistics_path, alert: 'Invalid year selected.'
    end
  end

  def fetch_available_years
    @available_years = @current_member.library_entries
                                      .where.not(watched_date: nil)
                                      .pluck(Arel.sql('EXTRACT(YEAR FROM watched_date)'))
                                      .uniq
                                      .map(&:to_i)
                                      .sort
                                      .reverse
  end
end
