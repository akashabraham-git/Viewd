class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  before_action :set_global_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_global_user
    @current_user = current_user
  end

  def authorize_moderator!
    unless @current_user&.actable_type == 'Moderator'
      redirect_to root_path, alert: "Only moderators can do that."
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :username, 
      actable_attributes: [:id, :bio]
    ])
  end

  def after_sign_in_path_for(resource)
    user_path(resource)
  end

end