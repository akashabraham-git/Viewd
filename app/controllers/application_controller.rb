class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def authorize_moderator!
    @current_user = User.find(13) 
    unless @current_user.actable_type == 'Moderator'
      redirect_to root_path, alert: "Only moderators can do that."
    end
  end

end
