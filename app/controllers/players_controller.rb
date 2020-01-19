class PlayersController < ApplicationController
  before_action :verify_user_logged_in, except: [:show]
  before_action :load_record, only: [:show, :edit, :update]

  def show
    @success_of_play = SuccessOfPlay.result_for(player: @player, season: selected_season)
  end

  def edit
    @heading = @player.name
  end

  def update
    @heading = @player.name

    if @player.update(player_params)
      redirect_to enrollments_path, notice: true
    else
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
