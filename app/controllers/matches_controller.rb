class MatchesController < ApplicationController
  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :load_season, only: [:index]
  before_action :load_round, only: [:index]
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  def index
    if @round.present?
      @published_matches = PublishedMatchesQuery.call(round: @round)

      if user_signed_in?
        @draft_matches = DraftMatchesQuery.call(round: @round)
      end
    else
      @published_matches = Match.none
      @draft_matches = Match.none
    end
  end

  def show
  end

  def new
    @match = Match.new
  end

  def create
    @match = CreateMatch.call(match_params.merge(type: 'MatchManual')).result

    if @match.persisted?
      redirect_to @match
    else
      render :new
    end
  end

  def edit
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
    return if @season.nil?

    @round = if params[:round_id]
      @season.rounds.find(params[:round_id])
    else
      @season.rounds.default.first
    end
  end

  def set_match
    @match = policy_scope(Match).find(params[:id])
  end

  def match_params
    params.require(:match).permit(:player1_id, :player2_id, :round_id, :published, :note)
  end
end
