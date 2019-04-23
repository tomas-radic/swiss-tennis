require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Players", type: :request do
  let!(:user) { create(:user) }
  let!(:category) { create(:category) }

  describe "GET /players" do
    subject(:get_players) { get players_path }

    it "Renders index template and responds with success" do
      get_players
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /player/abc" do
    subject(:get_player) { get player_path(player) }

    let!(:player) { create(:player) }

    it "Renders show template and responds with success" do
      get_player
      expect(response).to render_template(:show)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /players/new" do
    subject(:get_players_new) { get new_player_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "returns a success response" do
        get_players_new
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_players_new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /players/abc/edit" do
    subject(:get_player_edit) { get edit_player_path(player) }

    let!(:player) { create(:player) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
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

  describe "POST /players" do
    subject(:post_players) { post players_path, params: params }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      context "With valid params" do
        let(:params) do
          { player: { first_name: 'Stefanos', last_name: 'Tsitsipas', category_id: category.id } }
        end

        it "Creates new player" do
          expect { post_players }.to change(Player, :count).by(1)
        end

        it "Redirects to list of players" do
          post_players
          expect(response).to redirect_to players_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { player: { first_name: 'Stefanos', last_name: 'Tsitsipas' } }
        end

        it "Does not create new player and renders new template" do
          expect{ post_players }.not_to change(Player, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { player: { first_name: 'Stefanos', last_name: 'Tsitsipas', category_id: category.id } }
      end

      it 'Redirects to login' do
        post_players
        expect(response).to redirect_to login_path
      end

      it 'Does not create new player' do
        expect { post_players }.not_to change(Player, :count)
      end
    end
  end

  describe "PUT /players/abc" do
    subject(:put_players) { put player_path(player), params: params }

    let!(:player) { create(:player) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      context "With valid params" do
        let(:params) do
          { player: { first_name: 'Stefanos', last_name: 'Tsitsipas', category_id: category.id } }
        end

        it "Updates the requested player" do
          expect { put_players }.not_to change(Player, :count)
          player.reload

          expect(player.first_name).to eq 'Stefanos'
          expect(player.last_name).to eq 'Tsitsipas'
          expect(player.category).to eq category
        end

        it "Redirects to list of players" do
          put_players
          expect(response).to redirect_to players_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { player: { first_name: 'Stefanos', last_name: 'Tsitsipas', category_id: nil } }
        end

        it "Does not change the player and renders edit template" do
          put_players
          player.reload

          expect(player.first_name).not_to eq 'Stefanos'
          expect(player.last_name).not_to eq 'Tsitsipas'
          expect(player.category).not_to eq category
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { player: { first_name: 'Stefanos', last_name: 'Tsitsipas', category_id: category.id } }
      end

      it 'Redirects to login' do
        put_players
        expect(response).to redirect_to login_path
      end

      it 'Does not update the player' do
        put_players
        expect(player.first_name).not_to eq 'Stefanos'
        expect(player.last_name).not_to eq 'Tsitsipas'
        expect(player.category).not_to eq category
      end
    end
  end
end
