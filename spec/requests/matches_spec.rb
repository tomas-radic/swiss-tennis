require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Matches", type: :request do
  let!(:user) { create(:user) }

  describe "GET /matches" do
    subject(:get_matches) { get matches_path }

    it "Renders index template and responds with success" do
      get_matches
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end
end
