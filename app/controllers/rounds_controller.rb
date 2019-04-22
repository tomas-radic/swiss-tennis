class RoundsController < ApplicationController
  before_action :verify_user_logged_in
  before_action :set_round, only: [:show, :edit, :update, :destroy]

  def index
    load_default_season
    @rounds = Round.all
  end

  def show
  end

  def new
    @round = Round.new
  end

  def edit
    @heading = @round.full_label
  end

  def create
    @round = Round.new(round_params)


    if @round.save
      redirect_to @round
    else
      render :new
    end
  end

  def update

    if @round.update(round_params)
      redirect_to @round
    else
      render :edit
    end
  end

  def destroy
    @round.destroy
    redirect_to rounds_url
  end

  private

  def set_round
    @round = Round.find(params[:id])
  end

  def round_params
    params.require(:round).permit(:label, :period_begins, :period_ends, :season_id)
  end

  def load_default_season
    @season = Season.last
  end
end
