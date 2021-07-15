class PlayersController < ApplicationController

  before_action :verify_user_logged_in, except: [:show]
  before_action :load_record, only: [:show, :edit, :update]


  def show
    seasons = Season.default

    @recent_matches = Match.finished
                           .where("finished_at >= ?", 2.month.ago)
                           .where("player1_id = ? or player2_id = ?", @player.id, @player.id)
                           .where("set1_player1_score > 0 or set1_player2_score > 0")
                           .reorder(:finished_at).last(3)

    @success_of_play = []
    @success_of_play << SuccessOfPlay.result_for(player: @player, season: seasons[0]) if seasons[0]
    @success_of_play << SuccessOfPlay.result_for(player: @player, season: seasons[1]) if seasons[1]

    if seasons[0] && seasons[1]
      @opponents_comparison = {
        current_opponents: @player.opponents_in(seasons[0]).map(&:id),
        previous_opponents: @player.opponents_in(seasons[1]).map(&:id)
      }
    end
  end


  def edit
    @heading = @player.name
  end


  def update
    if @player.update(player_params)
      redirect_to enrollments_path, notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end


  private


  def load_record
    @player = Player.default.find(params[:id])
  end


  def player_params
    params.require(:player).permit(
      :first_name, :last_name, :phone, :email, :consent_given, :birth_year, :category_id
    )
  end

end
