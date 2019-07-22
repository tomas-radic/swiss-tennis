class RankingsController < ApplicationController
  before_action :verify_user_logged_in, except: [:index]
  before_action :load_record, only: [:edit, :update]

  def index
    @rankings = RankingsQuery.call(round: selected_round)
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
end
