require 'rails_helper'

RSpec.describe "Rankings", type: :request do
  describe "GET /rankings" do
    subject(:get_rankings) { get rankings_path }

    it "Renders index template and responds with success" do
      get_rankings
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end
end
