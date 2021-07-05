require 'rails_helper'
require 'requests/requests_spec_helper'

Dir["./spec/requests/manager/shared_examples/*.rb"].sort.each { |f| require f }

include RequestsSpecHelper

RSpec.describe "Rounds", type: :request do

  let(:model) { Round }
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }

  let(:valid_params) do
    {
      round: {
        label: 'Finals'
      }
    }
  end

  let(:invalid_params) do
    { round: { season_id: "" } }
  end


  describe "GET /manager/rounds" do
    subject { get manager_rounds_path }

    it_behaves_like "manager_request_index"
  end


  describe "GET /manager/rounds/:id" do
    subject { get manager_round_path(record) }

    let!(:record) { create(:round) }

    it_behaves_like "manager_request_show"
  end


  describe "GET /manager/rounds/new" do
    subject { get new_manager_round_path }

    it_behaves_like "manager_request_new"
  end


  describe "POST /manager/rounds" do
    subject { post manager_rounds_path, params: params }

    context "When signed in as a user" do

      before do
        requests_login(user, 'password')
      end

      context "With valid params" do
        let(:params) { valid_params }

        it "Creates new record" do
          expect { subject }.to change{model.count}.by(1)
        end
      end
    end

    context "Signed out" do
      let(:params) { valid_params }

      it 'Redirects to login' do
        subject

        expect(response).to redirect_to login_path
      end
    end
  end


  describe "GET /manager/rounds/:id/edit" do
    subject { get edit_manager_round_path(record) }

    let!(:record) { create(:round) }

    it_behaves_like "manager_request_edit"
  end


  describe "PUT /manager/rounds/:id" do
    subject { put manager_round_path(record), params: params }

    let!(:record) { create(:round) }

    context 'When signed in as a user' do
      before(:each) do
        requests_login(user, 'password')
      end

      context "With valid params" do
        let(:params) { valid_params }

        it "Updates the record" do
          subject

          record.reload
          expect(record).to have_attributes(valid_params[model.to_s.underscore.to_sym])
        end
      end
    end

    context 'Signed out' do

      let(:params) { valid_params }

      it 'Does not update record and redirects to login' do
        subject

        record.reload
        expect(record).not_to have_attributes(valid_params[model.to_s.underscore.to_sym])
        expect(response).to redirect_to login_path
      end
    end
  end


  describe 'POST /manager/rounds/:id/toss_matches' do
    subject { post toss_matches_manager_round_path(record), params: params }

    let!(:record) { create(:round) }
    let(:toss_points) do
      {
          'player1_id' => '5',
          'player2_id' => '5' ,
          'player3_id' => '4' ,
          'player4_id' => '6'
      }
    end

    let(:params) do
      {
        id: record.id,
        toss_points: toss_points
      }
    end


    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it 'Calls TossRoundMatches with correct parameters' do
        expect(TossRoundMatches).to receive(:call).with(record, toss_points)

        subject
      end

      it "Redirects to the round" do
        subject

        expect(response).to redirect_to manager_round_path(record)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject

        expect(response).to redirect_to login_path
      end

      it 'Does not call TossRoundMatches' do
        expect(TossRoundMatches).not_to receive(:call)

        subject
      end
    end
  end

  describe "GET /manager/rounds/:id/publish_all_matches" do
    subject { get publish_all_matches_manager_round_path(record) }

    let!(:record) { create(:round) }
    let!(:r_match1) { create(:match, :draft, round: record) }
    let!(:r_match2) { create(:match, :draft, round: record) }

    let!(:next_round) { create(:round) }
    let!(:nr_match1) { create(:match, :draft, round: next_round) }
    let!(:nr_match2) { create(:match, :draft, round: next_round) }

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it 'Publishes all matches of given round' do
        subject

        record.reload
        expect(record.matches.published.count).to eq 2
        expect(record.matches.draft.count).to eq 0
      end

      it 'Does not publish matches of other rounds' do
        subject
        next_round.reload

        expect(next_round.matches.published.count).to eq 0
        expect(next_round.matches.draft.count).to eq 2
      end

      it "Redirects to given round" do
        subject

        expect(response).to redirect_to manager_round_path(record)
      end
    end


    context 'When logged out' do
      it 'Redirects to login' do
        subject

        expect(response).to redirect_to login_path
      end
    end
  end
end
