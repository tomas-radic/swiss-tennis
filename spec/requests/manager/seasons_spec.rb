require 'rails_helper'
require 'requests/requests_spec_helper'

Dir["./spec/requests/manager/shared_examples/*.rb"].sort.each { |f| require f }

include RequestsSpecHelper

RSpec.describe "Seasons", type: :request do

  let(:model) { Season }
  let!(:user) { create(:user) }

  let(:valid_params) do
    { season: { name: 'Name' } }
  end

  let(:invalid_params) do
    { season: { name: "" } }
  end


  describe "GET /manager/seasons" do
    subject { get manager_seasons_path }

    it_behaves_like "manager_request_index"
  end


  describe "GET /manager/seasons/:id" do
    subject { get manager_season_path(record) }

    let(:record) { create(:season) }

    it "Raises error" do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end
  end


  describe "GET /manager/seasons/new" do
    subject { get new_manager_season_path }

    it_behaves_like "manager_request_new"
  end


  describe "POST /manager/seasons" do
    subject { post manager_seasons_path, params: params }

    it_behaves_like "manager_request_create"


    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      context "With valid params" do
        let(:params) { valid_params }

        describe "Handling dummy player" do
          before do
            requests_login(user, 'password')
          end

          context "When dummy player is not existing" do
            it "Creates new season, new dummy player and enrolls dummy player to the season" do
              expect { subject }.to change(Season, :count).by(1)
              season = Season.all.order(:created_at).last
              dummy_player = Player.find_by!(dummy: true)
              expect(season.enrollments.find_by(player: dummy_player)).not_to be_nil
            end
          end

          context "When dummy player exists" do
            let!(:dummy_player) { create(:player, :dummy) }

            it "Creates new season and enrolls dummy player to it" do
              expect { subject }.to change(Season, :count).by(1)
              season = Season.all.order(:created_at).last
              expect(season.enrollments.find_by(player: dummy_player)).not_to be_nil
            end
          end
        end

        it "Redirects to /manager/rounds" do
          subject

          expect(response).to redirect_to manager_rounds_path
        end
      end
    end
  end


  describe "GET /manager/seasons/:id/edit" do
    subject { get edit_manager_season_path(record) }

    let!(:record) { create(:season) }

    it_behaves_like "manager_request_edit"
  end


  describe "PUT /manager/seasons/:id" do
    subject { put manager_season_path(record), params: params }

    let!(:record) { create(:season) }

    it_behaves_like "manager_request_update"
  end


  describe "DELETE /manager/seasons/:id" do
    subject { delete manager_season_path(record) }

    let!(:record) { create(:season) }
    let(:redirect_path) { manager_seasons_path }

    it_behaves_like "manager_request_destroy"
  end
end
