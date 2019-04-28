class PlayersController < ApplicationController
  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :load_season, only: [:create]
  before_action :set_player, only: [:show, :edit, :update]

  def index
    @players = Player.default.includes(:category).order('categories.name').order('players.created_at')
  end

  def show
  end

  def new
    @player = Player.new
  end

  def edit
    @heading = PlayerDecorator.new(@player).name
  end

  def create
    @player = CreatePlayer.call(player_params, @season).result

    if @player.persisted?
      redirect_to players_path
    else
      render :new
    end
  end

  def update
    @heading = PlayerDecorator.new(@player).name

    if @player.update(player_params)
      redirect_to players_path
    else
      render :edit
    end
  end

  private

  def set_player
    @player = Player.default.find(params[:id])
  end

  def player_params
    params.require(:player).permit(
      :first_name, :last_name, :phone, :email, :birth_year, :category_id
    )
  end

  def load_season
    @season = Season.default.first  # TODO: change later after seasons support added

    redirect_to root_path and return unless @season.present?
  end
end
