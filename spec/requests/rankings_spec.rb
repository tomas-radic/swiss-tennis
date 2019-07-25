require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Rankings", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }

  describe "GET /rankings" do
    subject(:get_rankings) { get rankings_path }

    it "Renders index template and responds with success" do
      get_rankings
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /rankings/abc/edit" do
    subject(:get_ranking_edit) { get edit_ranking_path(ranking) }

    let!(:ranking) { create(:ranking) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "returns a success response" do
        get_ranking_edit
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_ranking_edit
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "PUT /rankings/abc" do
    subject(:put_rankings) { put ranking_path(ranking), params: params }

    let!(:ranking) { create(:ranking, points: 2, toss_points: 2) }
    let(:params) do
      { ranking: { points: 3, toss_points: 3 } }
    end

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "Updates only toss_points for given ranking" do
        put_rankings
        ranking.reload

        expect(ranking.points).to eq 2
        expect(ranking.toss_points).to eq 3
      end

      it "Redirects to rankings of the ranking round" do
        put_rankings

        expect(response).to redirect_to rankings_path(round_id: ranking.round_id)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        put_rankings

        expect(response).to redirect_to login_path
      end

      it 'Does not update the ranking' do
        put_rankings

        expect { put_rankings }.not_to change(ranking, :points)
        expect { put_rankings }.not_to change(ranking, :toss_points)
      end
    end
  end
end
