class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      reset_remember_token!(user)

      redirect_to root_url
    else
      render :new
    end
  end

  def destroy
    nullify_remember_token!
    session[:user_id] = nil
    redirect_to login_url
  end

  private

  def reset_remember_token!(user)
    remember_token = SecureRandom.hex
    cookies.permanent[:remember_token] = remember_token
    user.update!(remember_token: remember_token)
  end

  def nullify_remember_token!
    cookies.delete(:remember_token)
    current_user.update!(remember_token: nil)
  end
end
