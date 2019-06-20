class RankingsController < ApplicationController
  before_action :verify_user_logged_in, except: [:index]
  before_action :load_season, only: [:index]
  before_action :load_round, only: [:index]
  before_action :load_record, only: [:edit, :update]

  def index
    @rankings = RankingsQuery.call(round: @round)
    @last_update_time = @rankings.pluck(:updated_at).max&.in_time_zone
  end

  def edit

  end

  def update
    @ranking.update!(permitted_params)
    redirect_to rankings_path(round_id: @ranking.round_id)
  end

  private

  def permitted_params
    params.require(:ranking).permit(:toss_points)
  end

  def load_record
    @ranking = Ranking.find(params[:id])
  end

  def load_season
    @season = if params[:season_id]
      Season.find(params[:season_id])
    else
      Season.default.first  # TODO: change later after seasons support added
    end
  end

  def load_round
    return if @season.nil?

    @round = @season.rounds.find_by(id: params[:round_id]) if params[:round_id]
    @round ||= @season.rounds.default.first
  end
end
