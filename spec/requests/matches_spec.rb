require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Matches", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }

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

  describe "GET /matches/new?round_id=abc" do
    subject(:get_matches_new) { get new_match_path(round_id: round.id) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "returns a success response" do
        get_matches_new
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_matches_new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /matches" do
    subject(:post_matches) { post matches_path, params: params }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      context "With valid params" do
        let(:params) do
          {
            match: {
              player1_id: player1.id,
              player2_id: player2.id,
              from_toss: false,
              round_id: round.id
            }
          }
        end

        it "Creates new match" do
          expect { post_matches }.to change(Match, :count).by(1)
        end

        it "Redirects to the round" do
          post_matches
          expect(response).to redirect_to round_path(round)
        end
      end

      context "With invalid params" do
        let(:params) do
          { match: { player1_id: player1.id, round_id: round.id } }
        end

        it "Does not create new match and renders new template" do
          expect{ post_matches }.not_to change(Match, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        {
          match: {
            player1_id: player1.id,
            player2_id: player2.id,
            from_toss: false,
            round_id: round.id
          }
        }
      end

      it 'Redirects to login' do
        post_matches
        expect(response).to redirect_to login_path
      end

      it 'Does not create new match' do
        expect { post_matches }.not_to change(Match, :count)
      end
    end
  end
end
