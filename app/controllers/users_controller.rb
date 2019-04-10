class UsersController < ApplicationController
  include Pundit

  before_action :verify_user_logged_in
  before_action :set_and_authorize_user, only: [:edit, :update]
  before_action :verify_current_password, only: [:update]
  after_action :verify_authorized

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to root_path
    else
      render :edit
    end
  end


  private

  def set_and_authorize_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def verify_current_password
    authenticated = current_user.authenticate(params[:current_password])

    unless authenticated
      @user.errors.add(:current_password, "je neplatné.")
      render :edit and return
    end
  end
end
