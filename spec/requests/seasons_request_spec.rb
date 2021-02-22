require 'rails_helper'
require 'requests/requests_spec_helper'

include RequestsSpecHelper

RSpec.describe "Seasons", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }

  describe "GET /seasons" do
    subject(:get_seasons) { get seasons_path }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "Renders index template and responds with success" do
        get_seasons
        expect(response).to render_template(:index)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_seasons
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /seasons/new" do
    subject(:get_seasons_new) { get new_season_path }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "returns a success response" do
        get_seasons_new
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_seasons_new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /seasons/abc/edit" do
    subject(:get_season_edit) { get edit_season_path(season) }

    let!(:season) { create(:season) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "returns a success response" do
        get_season_edit
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_season_edit
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /seasons" do
    subject(:post_seasons) { post seasons_path, params: params }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      let(:params) do
        { season: { name: 'Name' } }
      end

      it "Creates new season" do
        expect { post_seasons }.to change(Season, :count).by(1)
      end

      it "Redirects to rounds path" do
        post_seasons

        expect(Season.find_by(name: 'Name')).not_to be_nil
        expect(response).to redirect_to rounds_path
      end
    end

    context 'When logged out' do
      let(:params) do
        { season: { name: 'Name' } }
      end

      it 'Redirects to login' do
        post_seasons

        expect(response).to redirect_to login_path
      end

      it 'Does not create new season' do
        expect { post_seasons }.not_to change(Season, :count)
      end
    end
  end

  describe "PUT /seasons/abc" do
    subject(:put_seasons) { put season_path(season), params: params }

    let!(:season) { create(:season) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      let(:params) do
        { season: { name: 'Name' } }
      end

      it "Updates given season" do
        put_seasons
        season.reload

        expect(season.name).to eq 'Name'
      end

      it "Redirects to seasons" do
        put_seasons

        expect(response).to redirect_to seasons_path
      end
    end

    context 'When logged out' do
      let(:params) do
        { season: { name: 'Name' } }
      end

      it 'Redirects to login' do
        put_seasons

        expect(response).to redirect_to login_path
      end

      it 'Does not update the season' do
        put_seasons

        expect { put_seasons }.not_to change(season, :name)
      end
    end
  end


  describe "DELETE /seasons/abc" do
    subject(:delete_seasons) { delete season_path(season) }

    let!(:season) { create(:season) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "Destroys given season" do
        id = season.id
        delete_seasons

        expect(Season.find_by(id: id)).to be_nil
      end

      it "Redirects to seasons" do
        delete_seasons

        expect(response).to redirect_to seasons_path
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        delete_seasons

        expect(response).to redirect_to login_path
      end

      it 'Does not destroy the season' do
        delete_seasons

        expect { delete_seasons }.not_to change(Season, :count)
      end
    end
  end
end
