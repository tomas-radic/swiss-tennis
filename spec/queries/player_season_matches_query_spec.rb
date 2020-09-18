require 'rails_helper'

describe PlayerSeasonMatchesQuery do
  subject(:query) { described_class.call(player: player1, season: season) }

  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }

  let!(:season) { create(:season) }
  let!(:s_round1) { create(:round, season: season) }
  let!(:s_round2) { create(:round, season: season) }
  let!(:s_round3) { create(:round, season: season) }
  let!(:s_match1) { create(:match, :finished, round: s_round1, player1: player1, player2: player2, players: [player1, player2], finished_at: 1.day.ago) }
  let!(:s_match2) { create(:match, :finished, round: s_round2, player1: player2, player2: player1, players: [player2, player1], finished_at: 3.days.ago) }
  let!(:s_match3) { create(:match, :draft, round: s_round3, player1: player2, player2: player1, players: [player2, player1]) }

  let!(:previous_season) { create(:season) }
  let!(:ps_round1) { create(:round, season: previous_season) }
  let!(:ps_match1) { create(:match, round: ps_round1, player1: player1, player2: player2, players: [player1, player2]) }

  it 'Returns matches of given player in given season' do
    result = query

    expect(result.length).to eq 2
    expect(result[0]).to eq(s_match2)
    expect(result[1]).to eq(s_match1)
  end
end
