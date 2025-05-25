class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorised

  private

  def user_not_authorised
    flash[:alert] = "You are not authorised to perform this action."
    redirect_to(request.referer || root_path)
  end
end
