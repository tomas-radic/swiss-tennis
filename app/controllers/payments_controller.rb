class PaymentsController < ApplicationController
  before_action :verify_user_logged_in

  def index
    @payments = Payment.all.paginate(page: params[:page], per_page: 5).sorted
  end
end