class ArticlesController < ApplicationController
  before_action :verify_user_logged_in, except: [:index, :show]
  before_action :load_record, only: [:show, :edit, :update, :destroy, :pin]

  def index
    @articles = Article.sorted.where(season: selected_season).includes(:user)
  end

  def show
    authorize @article
  end

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
      redirect_to articles_path
    else
      render :new
    end
  end

  def edit
    @heading = @article.title
  end

  def update
    if @article.update(whitelisted_params)
      redirect_to article_path(@article)
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path
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
    @article = Article.find(params[:id])
  end
end
