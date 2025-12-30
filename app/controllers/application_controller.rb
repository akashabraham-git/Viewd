class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  before_action :set_global_user

  private

  def set_global_user
    @current_user = User.second
    @user = User.second
  end

  def authorize_moderator!
    unless @current_user&.actable_type == 'Moderator'
      redirect_to root_path, alert: "Only moderators can do that."
    end
  end
end