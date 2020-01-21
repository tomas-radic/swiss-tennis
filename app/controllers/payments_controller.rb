class PaymentsController < ApplicationController
  before_action :verify_user_logged_in

  def index
    @payments = Payment.sorted.paginate(page: params[:page], per_page: 10)
  end
end
