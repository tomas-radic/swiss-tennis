class ApplicationController < ActionController::Base
  include Pundit
  before_action :calculate_payment_balance, if: :user_signed_in?
  before_action :set_paper_trail_whodunnit

  protect_from_forgery with: :exception
  helper_method :current_user,
                :user_signed_in?,
                :selected_season,
                :selected_round

  add_flash_types :completed


  private

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies[:remember_token]
      @current_user ||= User.find_by(remember_token: cookies[:remember_token])
      session[:user_id] = @current_user&.id
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
    return @selected_season if @selected_season

    unless cookies[:selected_season_id].blank?
      @selected_season = Season.find_by(id: cookies[:selected_season_id])

      if @selected_season
        set_selected_season_cookie(@selected_season)
      else
        cookies.delete(:selected_season_id)
      end
    end

    @selected_season ||= Season.default.first
  end


  def selected_round
    @selected_round ||= SelectedRound.result_for(
      selected_season,
      round_id: params[:round_id]
    )
  end


  def set_selected_season_cookie(season)
    cookies.delete(:selected_season_id)
    cookies[:selected_season_id] = { value: season.id, expires: 10.minutes }
  end

  # def not_found!
  #   raise ActionController::RoutingError.new('Not Found')
  # end


  def calculate_payment_balance
    @payment_balance = Rails.cache.fetch(
        "payment_balance",
        expires_in: Rails.configuration.cached_hours_payment_balance.hours) do

      Payment.all.inject(0) { |sum, p| sum += p.amount }
    end

    @payment_balance_text = helpers.currency_string(@payment_balance)
  end


  def log_http_request!
    path = request.fullpath
    year = Date.today.year
    week = Date.today.cweek
    # ip_address = request.remote_ip

    http_request = HttpRequest.where(
      path: path,
      year: year,
      week: week).first_or_initialize(count: 0)

    http_request.count += 1
    http_request.save
  end
end
