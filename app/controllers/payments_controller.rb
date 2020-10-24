class PaymentsController < ApplicationController
  before_action :verify_user_logged_in

  def index
    @payments = Payment.sorted.paginate(page: params[:page], per_page: 10)
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(whitelisted_params.merge(user: current_user))

    if @payment.save
      redirect_to payments_path, notice: true
    else
      render :new
    end
  end


  private

  def whitelisted_params
    params.require(:payment).permit(:amount, :paid_on, :description)
  end
end
