require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Payments", type: :request do
  let!(:user) { create(:user) }

  describe "GET /payments" do
    subject(:get_payments) { get payments_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "Renders index template and responds with success" do
        get_payments
        expect(response).to render_template(:index)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_payments
        expect(response).to redirect_to login_path
      end
    end
  end
end
