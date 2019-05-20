class RankingsController < ApplicationController
  before_action :load_season, only: [:index]
  before_action :load_round, only: [:index]

  def index
    @rankings = RankingsQuery.call(round: @round)
    @last_update_time = @rankings.pluck(:updated_at).max&.in_time_zone
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

    @round = @season.rounds.find_by(id: params[:round_id]) if params[:round_id]
    @round ||= @season.rounds.default.first
  end
end
