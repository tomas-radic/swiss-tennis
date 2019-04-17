require 'rails_helper'

RSpec.describe "Seasons", type: :request do
  describe "GET /seasons" do
    it "works! (now write some real specs)" do
      get seasons_path
      expect(response).to have_http_status(200)
    end
  end
end
