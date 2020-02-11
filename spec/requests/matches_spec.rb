require 'rails_helper'
require 'requests/authentication_helper'

include AuthenticationHelper

RSpec.describe "Matches", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:player1) { create(:player, seasons: [season], rounds: [round]) }
  let!(:player2) { create(:player, seasons: [season], rounds: [round]) }

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
          login(user, 'password')
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
        login(user, 'password')
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
        login(user, 'password')
      end

      context "With valid params" do
        let(:params) do
          {
            match: {
              player1_id: player1.id,
              player2_id: player2.id,
              round_id: round.id
            }
          }
        end

        it "Calls CreateMatch with expected parameters" do
          expect(CreateMatch).to receive(:call).with(
              ActionController::Parameters.new(
                  player1_id: player1.id,
                  player2_id: player2.id,
                  round_id: round.id,
                  from_toss: false).permit!
          ).and_return(OpenStruct.new(result: Match.new(round: round)))

          post_matches
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

        it "Calls CreateMatch with expected parameters" do
          expect(CreateMatch).to receive(:call).with(
              ActionController::Parameters.new(
                  player1_id: player1.id,
                  round_id: round.id,
                  from_toss: false).permit!
          ).and_return(OpenStruct.new(result: Match.new(round: round)))

          post_matches
        end

        it "Renders new template" do
          post_matches

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

      it 'Does not call CreateMatch' do
        expect(CreateMatch).not_to receive(:call)

        post_matches
      end
    end
  end

  describe "GET /match/abc/edit" do
    subject(:get_match_edit) { get edit_match_path(match) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      let!(:match) { create(:match) }

      it "returns a success response" do
        get_match_edit
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      let!(:match) { create(:match) }

      it 'Redirects to login' do
        get_match_edit
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "PUT /matches/abc" do
    subject(:put_matches) { put match_path(match), params: params }

    let(:params) do
      {
        match: {
          player1_id: player1.id,
          player2_id: player2.id,
          from_toss: true,
          round_id: round.id,
          play_date: Date.tomorrow.to_s,
          note: 'Any note',
          published: false
        }
      }
    end

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      let!(:match) { create(:match) }

      it "Updates only allowed attributes" do
        put_matches
        match.reload

        expect(match.play_date).to eq(Date.tomorrow)
        expect(match.note).to eq('Any note')
        expect(match.published).to be false
        expect(match.player1).not_to eq(player1)
        expect(match.player2).not_to eq(player2)
        expect(match.from_toss?).not_to be true
        expect(match.round).not_to eq(round)
      end

      it "Redirects to the match" do
        put_matches
        expect(response).to redirect_to match_path(match)
      end
    end

    context 'When logged out' do
      let!(:match) { create(:match) }

      it 'Redirects to login' do
        put_matches

        expect(response).to redirect_to login_path
      end

      it 'Does not update the match' do
        put_matches

        expect(match.note).not_to eq('Any note')
      end
    end
  end

  describe "DELETE /matches/abc" do
    subject(:delete_matches) { delete match_path(match) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      context 'With unfinished match' do
        let!(:match) { create(:match, round: round) }

        it "Destroys the requested match" do
          expect { delete_matches }.to change(Match, :count).by(-1)
        end

        it "Redirects to the match round" do
          delete_matches

          expect(response).to redirect_to(round_path(round))
        end
      end

      context 'With finished match' do
        let!(:match) { create(:match, :finished, round: round) }

        it 'Raises error' do
          expect { delete_matches }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    context 'When logged out' do
      let!(:match) { create(:match, round: round) }

      it 'Redirects to login' do
        delete_matches

        expect(response).to redirect_to login_path
      end

      it 'Does not destroy the match' do
        expect { delete_matches }.not_to change(Match, :count)
      end
    end
  end

  describe "POST /match/abc/finish" do
    subject(:finish_match) do
      post finish_match_path(match, params:
        {
          score: {
            set1_player1: '6',
            set1_player2: '4',
            set2_player1: '6',
            set2_player2: '3',
            set3_player1: '',
            set3_player2: ''
          }
        }
      )
    end

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      context 'With unfinished match' do
        let!(:match) { create(:match, round: round) }
        let!(:player1_ranking) { create(:ranking, player: match.player1, round: round) }
        let!(:player2_ranking) { create(:ranking, player: match.player2, round: round) }

        it "Redirects to the match" do
          finish_match

          expect(response).to redirect_to(match_path(match))
        end
      end

      context 'With finished match' do
        let!(:match) { create(:match, :finished, round: round) }

        it 'Raises error' do
          expect { subject }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    context 'When logged out' do
      let!(:match) { create(:match, round: round) }

      it 'Redirects to login' do
        subject

        expect(response).to redirect_to login_path
      end

      it 'Does not finish the match' do
        expect { subject }.not_to change(Match, :count)
      end
    end
  end

  describe "GET /match/abc/swap_players" do
    subject(:swap_players) do
      get swap_players_match_path(match)
    end

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      context 'With unfinished match' do
        let!(:match) { create(:match, round: round) }

        it "Calls SwapPlayers and redirects to the match" do
          expect(SwapMatchPlayers).to receive(:call).with(match)
          swap_players

          expect(response).to redirect_to(match_path(match))
        end
      end

      context 'With finished match' do
        let!(:match) { create(:match, :finished, round: round) }

        it 'Raises error' do
          expect { swap_players }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    context 'When logged out' do
      let!(:match) { create(:match, round: round) }

      it 'Redirects to login' do
        swap_players

        expect(response).to redirect_to login_path
      end

      it 'Does not swap the players' do
        expect { swap_players }.not_to change(Match, :count)
      end
    end
  end
end
