class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    else
      @current_user = nil
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def verify_user_logged_in
    redirect_to login_path and return if current_user.nil?
  end

  def current_season
    # TODO
  end

  def current_round
    # TODO
  end
end
