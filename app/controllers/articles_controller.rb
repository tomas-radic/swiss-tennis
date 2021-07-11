class ArticlesController < ApplicationController

  before_action :load_record, only: [:show, :load_content]

  def index
    @articles = policy_scope(Article).sorted
                    .where(season: selected_season)
                    .includes(:user)
                    .paginate(page: params[:page], per_page: 10)
  end


  def show
    authorize @article
  end


  def load_content
    authorize @article

    respond_to do |format|
      format.js
    end
  end


  private

  def load_record
    @article = Article.find params[:id]
  end
end
