class RoundsController < ApplicationController
  before_action :verify_user_logged_in
  before_action :load_record, only: [:show, :edit, :update, :toss_matches, :publish_all_matches]

  def index
    @rounds = selected_season.rounds.order(position: :asc).includes(:matches, :finished_matches)
  end

  def show
    @players_without_match = PlayersWithoutMatchQuery.call(round: @round).includes(:rankings)


    @planned_matches = @round.matches.planned
                         .order("play_date asc, play_time asc, note desc nulls last")
                         .includes(:round, :place, {
                           player1: :rankings, player2: :rankings
                         })

    @recent_matches = @round.matches.recent
                        .order("finished_at desc")
                        .includes(:round, :place, {
                          player1: :rankings, player2: :rankings
                        }, :winner, :retired_player)

    @previous_matches = @round.matches.previous
                          .order("finished_at desc")
                          .includes(:round, :place, {
                            player1: :rankings, player2: :rankings
                          }, :winner, :retired_player)

    @unplanned_matches = @round.matches.pending
                           .where(play_date: nil)
                           .order("rounds.position desc, matches.note desc nulls last")
                           .includes(:round, :place, {
                             player1: :rankings, player2: :rankings
                           })

    # Counts
    @nr_published_matches = @planned_matches.published.count +
      @recent_matches.published.count +
      @previous_matches.published.count +
      @unplanned_matches.published.count

    @nr_draft_matches = @planned_matches.draft.count +
      @recent_matches.draft.count +
      @previous_matches.draft.count +
      @unplanned_matches.draft.count


    if selected_round.period_ends && ((selected_round.period_ends - 7) < Date.today)
      @unplanned_matches_count = @round.matches.published.pending.not_dummy.count
    end
  end

  def new
    @round = selected_season.rounds.new
  end

  def edit
    @heading = @round.full_label
  end

  def create
    @round = CreateRound.call(
      params.require(:round).permit(:label, :period_begins, :period_ends, :season_id)
    ).result

    if @round.persisted?
      redirect_to @round, notice: true
    else
      render :new
    end
  end

  def update
    if @round.update(whitelisted_params)
      redirect_to @round, notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end

  def toss_matches
    TossRoundMatches.call(
      @round,
      params[:toss_points]
    )

    flash[:completed] = 'toss'
    redirect_to @round
  end

  def publish_all_matches
    @round.matches.update_all(published: true)

    redirect_to @round, notice: true
  end

  private

  def load_record
    @round = Round.find(params[:id])
  end

  def whitelisted_params
    params.require(:round).permit(:label, :period_begins, :period_ends, :specific_purpose)
  end
end
