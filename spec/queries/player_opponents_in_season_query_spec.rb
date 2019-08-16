require 'rails_helper'

describe PlayerOpponentsInSeasonQuery do
  subject(:query) { described_class.call(player: player, season: season) }

  let!(:season) { create(:season, name: 'This season') }
  let!(:previous_season) { create(:season, name: 'Previous season') }

  let!(:season_round1) { create(:round, season: season, position: 1) }
  let!(:season_round2) { create(:round, season: season, position: 2) }
  let!(:season_round3) { create(:round, season: season, position: 3) }
  let!(:previous_season_round1) { create(:round, season: previous_season, position: 1) }
  let!(:previous_season_round2) { create(:round, season: previous_season, position: 2) }

  let!(:player) { create(:player) }

  let!(:season_round1_match) { create(:match, :finished, round: season_round1, player2: player) }
  let!(:season_round2_match) { create(:match, :finished, round: season_round2, player1: player) }
  let!(:season_round3_match) { create(:match, round: season_round3, player2: player) }
  let!(:previous_season_round1_match) { create(:match, round: previous_season_round1, player2: player) }
  let!(:previous_season_round2_match) { create(:match, round: previous_season_round2, player1: player) }

  it 'Returns finished matches opponents of given player in given season' do
    opponents = query

    expect(opponents.count).to eq 2
    expect(opponents).to match_array [season_round1_match.player1, season_round2_match.player2]
  end
end
