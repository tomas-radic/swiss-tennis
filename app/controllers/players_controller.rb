class PlayersController < ApplicationController
  before_action :verify_user_logged_in, except: [:show]
  before_action :load_record, only: [:show, :edit, :update]

  def show
    seasons = Season.default

    @success_of_play = []
    @success_of_play << SuccessOfPlay.result_for(player: @player, season: seasons[0]) if seasons[0]
    @success_of_play << SuccessOfPlay.result_for(player: @player, season: seasons[1]) if seasons[1]
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
