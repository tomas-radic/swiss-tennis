require 'rails_helper'

describe ResetSeasonRankings do
  skip "No more used" do
    subject(:service) { described_class.call(season) }

    let!(:season) { create(:season) }
    let!(:ranking1) { create(:ranking) }
    let!(:ranking2) { create(:ranking) }
    let(:rankings_hashes) do
      [
        {
          id: ranking1.id,
          player_id: ranking1.player_id,
          round_id: ranking1.round_id,
          points: 5,
          handicap: 15,
          sets_difference: 25,
          games_difference: 25,
          relevant: true
        },
        {
          id: ranking2.id,
          player_id: ranking2.player_id,
          round_id: ranking2.round_id,
          points: 7,
          handicap: 17,
          sets_difference: 27,
          games_difference: 27,
          relevant: true
        }
      ]
    end

    it 'Runs RecalculatedRankings calculation and updates existing rankings' do
      expect(RecalculatedRankings).to receive(:result_for).with(season: season).and_return(rankings_hashes)

      service

      expect(ranking1.reload).to have_attributes(
        points: 5,
        handicap: 15,
        sets_difference: 25,
        games_difference: 25,
        relevant: true
      )
      expect(ranking2.reload).to have_attributes(
        points: 7,
        handicap: 17,
        sets_difference: 27,
        games_difference: 27,
        relevant: true
      )
    end
  end
end
