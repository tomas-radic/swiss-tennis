require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Rounds", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }

  describe "GET /rounds" do
    subject(:get_rounds) { get rounds_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "Renders index template and responds with success" do
        get_rounds
        expect(response).to render_template(:index)
        expect(response).to have_http_status(200)
      end

      context 'When there is no season' do
        before { Season.destroy_all }

        it 'Redirects to root' do
          expect(response).to redirect_to root_path
          get_rounds
        end
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_rounds
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /round/abc" do
    subject(:get_round) { get round_path(round) }

    let!(:round) { create(:round) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "Renders show template and responds with success" do
        get_round
        expect(response).to render_template(:show)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_round
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /rounds/new" do
    subject(:get_rounds_new) { get new_round_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "returns a success response" do
        get_rounds_new
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_rounds_new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /rounds/abc/edit" do
    subject(:get_round_edit) { get edit_round_path(round) }

    let!(:round) { create(:round) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "returns a success response" do
        get_round_edit
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_round_edit
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /rounds" do
    subject(:post_rounds) { post rounds_path, params: params }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      let(:params) do
        { round: { season_id: season.id, label: 'Finals' } }
      end

      it "Creates new round" do
        expect { post_rounds }.to change(Round, :count).by(1)
      end

      it "Redirects to created round" do
        post_rounds
        round = Round.find_by(label: 'Finals')

        expect(response).to redirect_to round_path(round)
      end
    end

    context 'When logged out' do
      let(:params) do
        { round: { season_id: season.id } }
      end

      it 'Redirects to login' do
        post_rounds

        expect(response).to redirect_to login_path
      end

      it 'Does not create new round' do
        expect { post_rounds }.not_to change(Round, :count)
      end
    end
  end

  describe "PUT /rounds/abc" do
    subject(:put_rounds) { put round_path(round), params: params }

    let!(:round) { create(:round) }
    let!(:other_season) { create(:season) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      let(:params) do
        { round: { season_id: other_season.id, period_begins: Date.today.to_s, period_ends: Date.tomorrow.to_s } }
      end

      it "Updates given round" do
        put_rounds
        round.reload

        expect(round.period_begins).to eq Date.today
        expect(round.period_ends).to eq Date.tomorrow
      end

      it 'Does not update season' do
        put_rounds

        expect(round.season).not_to eq other_season
      end

      it "Redirects to updated round" do
        put_rounds

        expect(response).to redirect_to round_path(round)
      end
    end

    context 'When logged out' do
      let(:params) do
        { round: { period_begins: Date.today.to_s, period_ends: Date.tomorrow.to_s } }
      end

      it 'Redirects to login' do
        put_rounds

        expect(response).to redirect_to login_path
      end

      it 'Does not update the round' do
        put_rounds

        expect { put_rounds }.not_to change(round, :period_begins)
        expect { put_rounds }.not_to change(round, :period_ends)
      end
    end
  end

  describe 'POST /rounds/abc/toss_matches' do
    subject(:post_toss_matches_round) { post toss_matches_round_path(round), params: params }

    let!(:round) { create(:round) }
    let!(:ranking1) { create(:ranking, round: round) }
    let!(:ranking2) { create(:ranking, round: round) }
    let!(:ranking3) { create(:ranking, round: round) }
    let!(:ranking4) { create(:ranking, round: round) }
    let(:params) do
      {
        id: round.id,
        players_in_toss: [
          ranking1.player_id,
          ranking2.player_id,
          ranking3.player_id,
          ranking4.player_id
        ]
      }
    end

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "Creates matches for the round" do
        post_toss_matches_round
        round.reload

        expect(round.matches.count).to eq 2
      end

      it "Redirects to the round" do
        post_toss_matches_round

        expect(response).to redirect_to round_path(round)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        post_toss_matches_round

        expect(response).to redirect_to login_path
      end

      it 'Does not create matches for the round' do
        post_toss_matches_round
        round.reload

        expect(round.matches.count).to eq 0
      end
    end
  end

  describe "GET /rounds/abc/publish_all_matches" do
    subject(:get_round_publish_all_matches) { get publish_all_matches_round_path(round) }

    let!(:round) { create(:round) }
    let!(:r_match1) { create(:match, :draft, round: round) }
    let!(:r_match2) { create(:match, :draft, round: round) }

    let!(:next_round) { create(:round) }
    let!(:nr_match1) { create(:match, :draft, round: next_round) }
    let!(:nr_match2) { create(:match, :draft, round: next_round) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it 'Publishes all matches of given round' do
        get_round_publish_all_matches
        round.reload

        expect(round.matches.published.count).to eq 2
        expect(round.matches.draft.count).to eq 0
      end

      it 'Does not publish matches of other rounds' do
        get_round_publish_all_matches
        next_round.reload

        expect(next_round.matches.published.count).to eq 0
        expect(next_round.matches.draft.count).to eq 2
      end

      it "Redirects to given round" do
        get_round_publish_all_matches

        expect(response).to redirect_to round_path(round)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_round_publish_all_matches

        expect(response).to redirect_to login_path
      end
    end
  end
end
