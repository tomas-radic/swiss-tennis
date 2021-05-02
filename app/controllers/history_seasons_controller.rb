class HistorySeasonsController < ApplicationController

  def index

  end


  def show
    latest_season = Season.all.order(:created_at).last
    requested_season = Season.find_by(id: params[:id])

    if latest_season.nil? || requested_season.nil? || latest_season == requested_season
      cookies.delete(:selected_season_id)
      redirect_to root_path and return
    end

    set_selected_season_cookie(requested_season)
    redirect_to root_path
  end

end
