require 'rails_helper'

describe PlayerRankingsSinceRoundQuery do
  subject(:described_query) { PlayerRankingsSinceRoundQuery.call(player: player, round: round) }

  let!(:current_season) { create(:season) }
  let!(:previous_season) { create(:season) }
  let!(:c_round1) { create(:round, position: 1, season: current_season) }
  let!(:c_round2) { create(:round, position: 2, season: current_season) }
  let!(:c_round3) { create(:round, position: 3, season: current_season) }
  let!(:p_round1) { create(:round, position: 1, season: previous_season) }
  let!(:p_round2) { create(:round, position: 2, season: previous_season) }
  let!(:p_round3) { create(:round, position: 3, season: previous_season) }
  let!(:player) { create(:player) }
  let!(:c_ranking1) { create(:ranking, round: c_round1, player: player) }
  let!(:c_ranking2) { create(:ranking, round: c_round2, player: player) }
  let!(:c_ranking3) { create(:ranking, round: c_round3, player: player) }
  let!(:another_player_ranking) { create(:ranking, round: c_round3) }
  let!(:p_ranking1) { create(:ranking, round: p_round1, player: player) }
  let!(:p_ranking2) { create(:ranking, round: p_round2, player: player) }
  let!(:p_ranking3) { create(:ranking, round: p_round3, player: player) }

  let(:round) { c_round2 }

  it 'Returns player rankings since given round in the season' do
    rankings = described_query

    expect(rankings.length).to eq 2
    expect(rankings).to include(c_ranking2, c_ranking3)
  end
end
