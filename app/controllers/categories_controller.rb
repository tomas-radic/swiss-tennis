class CategoriesController < ApplicationController
  before_action :verify_user_logged_in
  before_action :load_record, only: [:edit, :update, :destroy]

  def index
    @categories = Category.sorted
    @undeletable_category_ids = Category.joins(:players).ids
  end

  def new
    @category = Category.new
  end

  def edit
    @heading = @category.name
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: true
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: true
    else
      @heading = params[:heading]
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: true
  end

  private

  def load_record
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :detail, :nr_finalists)
  end
end
