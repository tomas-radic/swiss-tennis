class RoundsController < ApplicationController
  before_action :verify_user_logged_in
  before_action :load_season, only: [:index, :show, :create]
  before_action :set_round, only: [:show, :edit, :update, :destroy]

  def index
    @rounds = @season.rounds.all
  end

  def show
    @players_without_match = @season.players.left_joins(:matches)
        .where('match_assignments.player_id is null')
  end

  def new
    @round = Round.new
  end

  def edit
    @heading = @round.full_label
  end

  def create
    @round = @season.rounds.new(round_params)

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

  private

  def load_season
    @season = if params[:season_id]
      Season.find(params[:season_id])
    else
      Season.default.first  # TODO: change later after seasons support added
    end
  end

  def set_round
    @round = Round.find(params[:id])
  end

  def round_params
    params.require(:round).permit(:label, :period_begins, :period_ends)
  end
end
