class MatchesController < ApplicationController

  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :load_record, only: [:show, :edit, :update, :destroy, :finish, :swap_players]


  def index
    log_http_request! unless user_signed_in?

    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first

    if selected_round.present?
      @matches = policy_scope(Match)
                   .default
                   .joins(:round)
                   .where(rounds: { season_id: selected_season.id })
                   .where("(rounds.position = ?) or (matches.finished_at is null and rounds.position < ?)",
                          selected_round.position, selected_round.position)
                   .includes(:round, :place, { player1: :rankings, player2: :rankings }, :winner, :retired_player)
    end

    @last_update_time = @matches.pluck(:updated_at).max&.in_time_zone

    if user_signed_in? && selected_round&.period_ends && (selected_round&.period_ends - 7 < Date.today)
      @unplanned_matches_count = UnplannedMatchesCount.result_for(@matches)
    end
  end


  def show

  end


  def new
    @round = selected_season.rounds.find(params[:round_id])
    @match = Match.new(round: @round)
    @available_players = PlayersWithoutMatchQuery.call(round: @round, include_dummy: true)
  end

  def create
    @match = CreateMatch.call(create_params.merge(from_toss: false)).result

    if @match.persisted?
      redirect_to @match.round, notice: true
    else
      @round = selected_season.rounds.find(@match.round_id)
      @available_players = PlayersWithoutMatchQuery.call(round: @round, include_dummy: true)
      render :new
    end
  end


  def edit
  end


  def update
    if @match.update(update_params)
      redirect_to @match, notice: true
    else
      render :edit
    end
  end


  def destroy
    authorize @match

    round = @match.round
    DestroyMatch.call(@match)
    redirect_to round_path(round), notice: true
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

    redirect_to @match, notice: true
  end


  def swap_players
    authorize @match

    SwapMatchPlayers.call(@match)
    redirect_to @match, notice: true
  end


  private

  def load_record
    @match = policy_scope(Match).find(params[:id])
  end


  def create_params
    params.require(:match).permit(
        :player1_id,
        :player2_id,
        :round_id,
        :published,
        :play_date,
        :play_time,
        :place_id,
        :note
    )
  end


  def update_params
    params.require(:match).permit(
        :published,
        :play_date,
        :play_time,
        :place_id,
        :note
    )
  end
end
