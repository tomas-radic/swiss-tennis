class Manager::SeasonsController < Manager::BaseController

  def index
    @seasons = Season.default
  end


  def new
    @season = Season.new
  end


  def create
    @season = Season.new(whitelisted_params)

    ActiveRecord::Base.transaction do
      if @season.save
        dummy_player = Player.where(dummy: true).first_or_create!(
          first_name: "Večný",
          last_name: "Looser",
          category: Category.where(name: "Dummy").first_or_create!)
        Enrollment.where(season: @season, player: dummy_player).first_or_create!

        redirect_to manager_rounds_path, notice: true
      else
        render :new
      end
    end
  end


  def edit
    @season = Season.find(params[:id])
    @heading = params[:heading] || @season.name
  end


  def update
    @season = Season.find(params[:id])

    if @season.update(whitelisted_params)
      redirect_to manager_seasons_path, notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end


  def destroy
    @season = Season.find(params[:id])
    @season.destroy

    redirect_to manager_seasons_path, notice: true
  end


  private

  def whitelisted_params
    params.require(:season).permit(:name)
  end

end
