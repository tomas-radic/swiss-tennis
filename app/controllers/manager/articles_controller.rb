class Manager::ArticlesController < Manager::BaseController

  before_action :load_record, only: [:edit, :update, :destroy, :pin]


  def new
    @article = Article.new(season: selected_season)
  end


  def create
    @article = Article.new(
      whitelisted_params.merge(
        season: selected_season,
        user: current_user
      )
    )

    if @article.save
      redirect_to article_path(@article), notice: true
    else
      render :new
    end
  end


  def edit
    @heading = @article.title
  end


  def update
    if @article.update(whitelisted_params)
      redirect_to article_path(@article), notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end


  def destroy
    @article.destroy
    redirect_to articles_path, notice: true
  end


  def pin
    PinArticle.call(@article)
    redirect_to @article
  end


  private

  def whitelisted_params
    params.require(:article).permit(
      :title,
      :content,
      :published,
      :last_date_interesting
    )
  end


  def load_record
    @article = Article.find params[:id]
  end
end
