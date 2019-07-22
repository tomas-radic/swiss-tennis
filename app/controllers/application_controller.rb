class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?, :selected_season, :selected_round

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

  def selected_season
    @selected_season ||= SelectedSeason.result_for(season_id: params[:season_id]) || not_found!
  end

  def selected_round
    @selected_round ||= SelectedRound.result_for(
      selected_season,
      round_id: params[:round_id]
    )
  end

  def not_found!
    raise ActionController::RoutingError.new('Not Found')
  end
end
