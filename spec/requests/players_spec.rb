require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Players", type: :request do
  let!(:season) { create(:season) }
  let!(:user) { create(:user) }
  let!(:category) { create(:category) }

  describe "GET /player/abc" do
    subject(:get_player) { get player_path(player) }

    let!(:player) { create(:player, seasons: [season]) }

    it "Renders show template and responds with success" do
      get_player
      expect(response).to render_template(:show)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /player/abc/edit" do
    subject(:get_player_edit) { get edit_player_path(player) }

    let!(:player) { create(:player) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "returns a success response" do
        get_player_edit
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_player_edit
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "PUT /players/abc" do
    subject(:put_players) { put player_path(player), params: params }

    let!(:player) { create(:player) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      context "With valid params" do
        let(:params) do
          { player: { first_name: 'Roger', last_name: 'Federer', category_id: category.id } }
        end

        it "Updates the requested player" do
          expect { put_players }.not_to change(Player, :count)
          player.reload

          expect(player.first_name).to eq 'Roger'
          expect(player.last_name).to eq 'Federer'
          expect(player.category).to eq category
        end

        it "Redirects to list of players" do
          put_players
          expect(response).to redirect_to enrollments_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { player: { first_name: 'Roger', last_name: 'Federer', category_id: nil } }
        end

        it "Does not change the player and renders edit template" do
          put_players
          player.reload

          expect(player.first_name).not_to eq 'Roger'
          expect(player.last_name).not_to eq 'Federer'
          expect(player.category).not_to eq category
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { player: { first_name: 'Roger', last_name: 'Federer', category_id: category.id } }
      end

      it 'Redirects to login' do
        put_players
        expect(response).to redirect_to login_path
      end

      it 'Does not update the player' do
        put_players
        expect(player.first_name).not_to eq 'Roger'
        expect(player.last_name).not_to eq 'Federer'
        expect(player.category).not_to eq category
      end
    end
  end
end
