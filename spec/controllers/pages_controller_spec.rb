require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET about' do
    subject(:get_about) { get :about }

    it 'Renders about template' do
      get_about
      expect(response).to render_template(:about)
    end

    it 'Responds with success' do
      get_about
      expect(response).to have_http_status(:ok)
    end
  end


  describe 'GET game_rules' do
    subject(:get_game_rules) { get :game_rules }

    it 'Renders game_rules template' do
      get_game_rules
      expect(response).to render_template(:game_rules)
    end

    it 'Responds with success' do
      get_game_rules
      expect(response).to have_http_status(:ok)
    end
  end
end
