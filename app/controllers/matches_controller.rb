class MatchesController < ApplicationController
  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :load_season, only: [:index]
  before_action :load_round, only: [:index]
  before_action :set_match, only: [:show, :edit, :update, :destroy, :finish, :swap_players]

  def index
    @matches_count = 0

    if @round.present?
      @published_matches = PublishedMatchesQuery.call(round: @round).includes(:winner)
      @last_update_time = @published_matches.pluck(:updated_at).max&.in_time_zone
      @matches_count += @published_matches.size

      if user_signed_in?
        @draft_matches = DraftMatchesQuery.call(round: @round)
        @matches_count += @draft_matches.size
      else
        @draft_matches = Match.none
      end
    else
      @published_matches = Match.none
      @draft_matches = Match.none
    end
  end

  def show
  end

  def new
    @season = Season.default.first
    @round = @season.rounds.find(params[:round_id])
    @match = Match.new(round: @round)
    @available_players = PlayersWithoutMatchQuery.call(round: @round, include_dummy: true)
  end

  def create
    @match = CreateMatch.call(create_params.merge(from_toss: false)).result

    if @match.persisted?
      redirect_to @match.round
    else
      @season = Season.default.first
      @round = @season.rounds.find(@match.round_id)
      @available_players = PlayersWithoutMatchQuery.call(round: @round)
      render :new
    end
  end

  def edit
  end

  def update
    if @match.update(update_params)
      redirect_to @match
    else
      render :edit
    end
  end

  def destroy
    authorize @match

    round = @match.destroy.round
    redirect_to round_path(round)
  end

  def finish
    authorize @match

    FinishMatch.call(
      @match,
      params[:score],
      attributes: {
        retired_player_id: params[:retired_player_id],
        note: params[:note]
      }
    )

    redirect_to @match
  end

  def swap_players
    authorize @match

    SwapMatchPlayers.call(@match)
    redirect_to @match
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

  def create_params
    params.require(:match).permit(
      :player1_id,
      :player2_id,
      :round_id,
      :published,
      :play_date,
      :note
    )
  end

  def update_params
    params.require(:match).permit(
      :published,
      :play_date,
      :note
    )
  end
end
