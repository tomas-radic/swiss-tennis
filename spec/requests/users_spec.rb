require 'rails_helper'
require 'requests/requests_spec_helper'

include RequestsSpecHelper

RSpec.describe "Users", type: :request do
  describe "GET /users/abc/edit" do
    subject { get "/users/#{user.id}/edit" }

    let!(:user) { create(:user, email: 'john@gmail.com', password: 'password') }

    context 'With logged in user' do
      context 'Editing self' do
        before(:each) do
          requests_login user, 'password'
        end

        it 'Renders edit form and responds with success' do
          subject
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(200)
        end
      end

      context 'Editing user while logged in as other user' do
        let!(:other_user) { create(:user, email: 'someone@somewhere.com', password: 'anything') }

        before(:each) do
          requests_login other_user, 'anything'
        end

        it 'Raises error' do
          expect{subject}.to raise_error Pundit::NotAuthorizedError
        end

      end
    end

    context 'With logged out user' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
