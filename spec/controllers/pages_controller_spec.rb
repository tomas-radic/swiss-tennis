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


  describe 'GET rules' do
    subject(:get_rules) { get :rules }

    it 'Renders rules template' do
      get_rules
      expect(response).to render_template(:rules)
    end

    it 'Responds with success' do
      get_rules
      expect(response).to have_http_status(:ok)
    end
  end
end
