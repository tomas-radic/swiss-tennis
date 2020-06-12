require 'rails_helper'
require 'requests/requests_spec_helper'

include RequestsSpecHelper

RSpec.describe "Places", type: :request do
  let!(:user) { create(:user, password: 'password') }
  let!(:place) { create(:place) }

  describe "GET /places" do
    subject { get places_path }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "Renders index template and responds with success" do
        subject
        expect(response).to render_template(:index)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /places/new" do
    subject { get new_place_path }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "returns a success response" do
        subject
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /places/abc/edit" do
    subject { get edit_place_path(place) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "returns a success response" do
        subject
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /places" do
    subject { post places_path, params: params }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      context "With valid params" do
        let(:params) do
          { place: { name: 'Place name' } }
        end

        it "Creates a new Place" do
          expect{subject}.to change(Place, :count).by(1)
        end

        it "Redirects to list of places" do
          subject
          expect(response).to redirect_to places_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { place: { name: '' } }
        end

        it "Does not create new place and renders new template" do
          expect{subject}.not_to change(Place, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { place: { name: 'Place name' } }
      end

      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end

      it 'Does not create the place' do
        expect{subject}.not_to change(Place, :count)
      end
    end
  end

  describe "PUT /places/abc" do
    subject { put place_path(place), params: params }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      context "With valid params" do
        let(:params) do
          { place: { name: 'Changed name' } }
        end

        it "Updates the requested place" do
          expect{subject}.not_to change(Place, :count)
          place.reload

          expect(place.name).to eq 'Changed name'
        end

        it "Redirects to list of places" do
          subject
          expect(response).to redirect_to places_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { place: { name: '' } }
        end

        it "Does not change the place and renders edit template" do
          subject
          place.reload

          expect(place.name).not_to eq ''
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { place: { name: 'Changed name' } }
      end

      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end

      it 'Does not update the place' do
        subject
        expect(place.name).not_to eq 'Changed name'
      end
    end
  end

  describe "DELETE /places/abc" do
    subject { delete place_path(place) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "Destroys the requested place" do
        expect{subject}.to change(Place, :count).by(-1)
      end

      it "Redirects to the places list" do
        subject
        expect(response).to redirect_to(places_path)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end

      it 'Does not destroy the place' do
        expect{subject}.not_to change(Place, :count)
      end
    end
  end
end
