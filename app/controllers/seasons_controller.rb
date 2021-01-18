class SeasonsController < ApplicationController
  before_action :verify_user_logged_in

  def index
    @seasons = Season.default
  end


  def new
    @season = Season.new
  end


  def create
    @season = Season.new(whitelisted_params)

    if @season.save
      redirect_to rounds_path, notice: true
    else
      render :new
    end
  end


  def edit
    @season = Season.find(params[:id])
    @heading = params[:heading] || @season.name
  end


  def update
    @season = Season.find(params[:id])

    if @season.update(whitelisted_params)
      redirect_to seasons_path, notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end


  private

  def whitelisted_params
    params.require(:season).permit(:name)
  end

end
