class HttpRequestsController < ApplicationController

  before_action :verify_user_logged_in


  def index
    @year = (params[:year] || Date.today.year).to_i
    @http_requests = HttpRequest.where(year: @year)
  end

end
