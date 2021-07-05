class Manager::BaseController < ApplicationController

  before_action :verify_user_logged_in

end
