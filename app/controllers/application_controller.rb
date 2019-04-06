class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def user_signed_in?
    current_user.present?
  end
end
