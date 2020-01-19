class RoundsController < ApplicationController
  before_action :verify_user_logged_in
  before_action :load_record, only: [:show, :edit, :update, :toss_matches, :publish_all_matches]

  def index
    @rounds = selected_season.rounds.all
  end

  def show
    @players_without_match = PlayersWithoutMatchQuery.call(round: @round).includes(:rankings)
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
      render :edit
    end
  end

  def toss_matches
    TossRoundMatches.call(
      @round,
      params[:players_in_toss]
    )

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
    params.require(:round).permit(:label, :period_begins, :period_ends)
  end
end
