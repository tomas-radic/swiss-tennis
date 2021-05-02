require 'rails_helper'

RSpec.describe "HistorySeasons", type: :request do

  describe "GET /history_seasons" do
    subject { get history_seasons_path }

    it "Renders index template" do
      expect(subject).to render_template(:index)
    end
  end


  describe "GET /history_seasons/:id" do
    subject { get history_season_path(season_id) }

    context "With existing seasons" do
      let!(:season1) { create(:season, name: "#{Date.today.year - 2}") }
      let!(:season2) { create(:season, name: "#{Date.today.year - 1}") }
      let!(:season3) { create(:season, name: "#{Date.today.year}") }

      before do
        season1.insert_at(1)
        season2.insert_at(2)
        season3.insert_at(3)
      end


      context "With id of an existing older season" do
        let(:season_id) { season2.id }

        before do
          cookies.delete(:selected_season_id)
        end

        it "Stores season id to a cookie and redirects to root page" do
          expect(subject).to redirect_to root_path
          expect(cookies[:selected_season_id]).to eq(season2.id)
        end
      end


      context "With id of the latest existing season" do
        let(:season_id) { season3.id }

        before do
          cookies[:selected_season_id] = "anything"
        end

        it "Deletes cookie and redirects to root page" do
          expect(subject).to redirect_to root_path
          expect(cookies[:selected_season_id]).to be_blank
        end
      end


      context "With non existing id" do
        let(:season_id) { "non-existing" }

        before do
          cookies[:selected_season_id] = "anything"
        end

        it "Deletes cookie and redirects to root page" do
          expect(subject).to redirect_to root_path
          expect(cookies[:selected_season_id]).to be_blank
        end
      end
    end

    context "Without any existing season" do
      let(:season_id) { "non-existing" }

      before do
        cookies[:selected_season_id] = "anything"
      end

      it "Deletes cookie and redirects to root page" do
        expect(subject).to redirect_to root_path
        expect(cookies[:selected_season_id]).to be_blank
      end

    end
  end
end
