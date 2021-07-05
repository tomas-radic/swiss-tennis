class Manager::RoundsController < Manager::BaseController

  before_action :load_record, only: [:show, :edit, :update, :destroy, :toss_matches, :publish_all_matches]


  def index
    @rounds = selected_season.rounds.order(position: :asc).includes(:matches, :finished_matches)
  end


  def show
    @players_without_match = PlayersWithoutMatchQuery.call(round: @round).includes(:rankings)
    @round_matches = @round.matches.includes(:round, :place, player1: :rankings, player2: :rankings)

    if selected_round.period_ends && (selected_round.period_ends - 7 < Date.today)
      @unplanned_matches_count = UnplannedMatchesCount.result_for(@round_matches)
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
      params.require(:round).permit(:label, :period_begins, :period_ends).merge(season_id: selected_season.id)
    ).result

    if @round.persisted?
      redirect_to manager_round_path(@round), notice: true
    else
      render :new
    end
  end


  def update
    if @round.update(whitelisted_params)
      redirect_to manager_round_path(@round), notice: true
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
    redirect_to manager_round_path(@round)
  end


  def publish_all_matches
    @round.matches.update_all(published: true)

    redirect_to manager_round_path(@round), notice: true
  end


  private

  def load_record
    @round = Round.find(params[:id])
  end


  def whitelisted_params
    params.require(:round).permit(:label, :period_begins, :period_ends, :specific_purpose)
  end
end
