require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Matches", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }

  describe "GET /matches" do
    subject(:get_matches) { get matches_path }

    it "Renders index template and responds with success" do
      get_matches
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /match/abc" do
    subject(:get_match) { get match_path(match) }

    context 'With published match' do
      let!(:match) { create(:match) }

      it "Renders show template and responds with success" do
        get_match
        expect(response).to render_template(:show)
        expect(response).to have_http_status(200)
      end
    end

    context 'With draft match' do
      let!(:match) { create(:match, :draft) }

      it 'Raises error' do
        expect { get_match }.to raise_error ActiveRecord::RecordNotFound
      end

      context 'With signed in user' do
        before(:each) do
          login(user, 'nbusr123')
        end

        it "Renders show template and responds with success" do
          get_match
          expect(response).to render_template(:show)
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
