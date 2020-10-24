require 'rails_helper'
require 'requests/requests_spec_helper'

include RequestsSpecHelper

RSpec.describe "Payments", type: :request do
  let!(:user) { create(:user) }

  describe "GET /payments" do
    subject(:get_payments) { get payments_path }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
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


  describe "GET /payments/new" do
    subject(:get_payments_new) { get new_payment_path }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "returns a success response" do
        get_payments_new
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_payments_new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /payments" do
    subject(:post_payments) { post payments_path, params: params }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      context "With valid params" do
        let(:params) do
          {
              payment: {
                  amount: -2000,
                  paid_on: Date.yesterday
              }
          }
        end

        it "Creates new payment" do
          expect { post_payments }.to change(Payment, :count).by(1)
        end

        it 'Sets current user to the created payment' do
          post_payments

          expect(Payment.sorted.first.user).to eq user
        end

        it "Redirects to the list of payments" do
          post_payments

          expect(response).to redirect_to payments_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { payment: { amount: 2000, paid_on: "" } }
        end

        it "Does not create new payment and renders new template" do
          expect{ post_payments }.not_to change(Payment, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        {
            payment: {
                amount: -2000,
                paid_on: Date.yesterday
            }
        }
      end

      it 'Redirects to login' do
        post_payments
        expect(response).to redirect_to login_path
      end

      it 'Does not create new payment' do
        expect { post_payments }.not_to change(Payment, :count)
      end
    end
  end
end
