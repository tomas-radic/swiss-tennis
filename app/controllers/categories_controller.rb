class CategoriesController < ApplicationController
  before_action :verify_user_logged_in, except: [:index]
  before_action :load_record, only: [:edit, :update, :destroy]

  def index
    @categories = Category.all.default
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
      redirect_to categories_path
    else
      render :new
    end
  end

  def update
    @heading = @category.name

    if @category.update(category_params)
      redirect_to categories_path
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private

  def load_record
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
