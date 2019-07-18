require 'rails_helper'

describe OutputSeasonRankingsErrors do
  subject(:service) { described_class.call(season) }

  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:ranking1) { create(:ranking, round: round) }
  let!(:ranking2) { create(:ranking, round: round) }
  let(:rankings_hashes) do
    [
      {
        id: ranking1.id,
        player_id: ranking1.player_id,
        round_id: ranking1.round_id,
        points: 5,
        toss_points: 5,
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
        toss_points: 7,
        handicap: 17,
        sets_difference: 27,
        games_difference: 27,
        relevant: true
      }
    ]
  end

  it 'Runs SeasonRankings calculation' do
    expect(SeasonRankings).to receive(:result_for).with({ season: season })
        .and_return(rankings_hashes)

    service
  end
end
