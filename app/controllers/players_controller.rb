class PlayersController < ApplicationController
  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  def index
    @players = Player.all.includes(:category).order('categories.name').order('players.created_at')
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
    @player = Player.new(player_params)

    if @player.save
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

  def destroy
    @player.destroy
    redirect_to players_url
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(
      :first_name, :last_name, :phone, :email, :birth_year, :category_id
    )
  end
end
