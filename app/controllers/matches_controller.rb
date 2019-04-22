class MatchesController < ApplicationController
  before_action :load_season, only: [:index]
  before_action :load_round, only: [:index]
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  def index
    @finished_matches = @round.matches.published.finished.includes(:player1, :player2, :winner)
    @planned_matches = @round.matches.published.planned.includes(:player1, :player2, :winner)
  end

  def show
  end

  def new
    @match = Match.new
  end

  def edit
  end

  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to @match
    else
      render :new
    end
  end

  def update
    if @match.update(match_params)
      redirect_to @match
    else
      render :edit
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_url
  end

  private

  def load_season
    @season = if params[:season_id]
      Season.find(params[:season_id])
    else
      Season.default.first  # TODO: change later after seasons support added
    end
  end

  def load_round
    @round = if params[:round_id]
      @season.rounds.find(params[:round_id])
    else
      @season.rounds.default.first
    end
  end

  def set_match
    @match = Match.find(params[:id])
  end

  def match_params
    params.require(:match).permit(:player1_id, :player2_id, :winner_id, :round_id, :type, :published, :note)
  end
end
