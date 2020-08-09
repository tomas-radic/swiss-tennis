class MatchesController < ApplicationController
  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :load_record, only: [:show, :edit, :update, :destroy, :finish, :swap_players]

  def index
    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first

    if selected_round.present?
      @matches = policy_scope(Match).default
          .where(matches: { round_id: selected_round.id })
          .includes(:round, :place, { player1: :rankings, player2: :rankings })
      @last_update_time = @matches.pluck(:updated_at).max&.in_time_zone
    else
      @matches = Match.none
    end

    @delayed_matches = DelayedMatchesQuery.call(round: selected_round)
    @last_update_time = (
        @matches.map(&:updated_at) + @delayed_matches.map(&:updated_at)
    ).max&.in_time_zone

    if user_signed_in? && selected_round.period_ends && (selected_round.period_ends - 7 < Date.today)
      unplanned_matches = @matches.published.pending
                              .joins('join players as p1 on p1.id = matches.player1_id')
                              .joins('join players as p2 on p2.id = matches.player2_id')
                              .where('p1.dummy is false and p2.dummy is false')
                              .where(play_date: nil).distinct

      @unplanned_matches_count = unplanned_matches.count + @delayed_matches.count
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

    round = @match.destroy.round
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
