class PlacesController < ApplicationController
  before_action :verify_user_logged_in
  before_action :load_record, only: [:edit, :update, :destroy]

  def index
    @places = Place.all.sorted
  end

  def new
    @place = Place.new
  end

  def edit
    @heading = @place.name
  end

  def create
    @place = Place.new(whitelisted_params)

    if @place.save
      redirect_to places_path, notice: true
    else
      render :new
    end
  end

  def update
    if @place.update(whitelisted_params)
      redirect_to places_path, notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end

  def destroy
    @place.destroy
    redirect_to places_path, notice: true
  end

  private

  def load_record
    @place = Place.find(params[:id])
  end

  def whitelisted_params
    params.require(:place).permit(:name)
  end
end
