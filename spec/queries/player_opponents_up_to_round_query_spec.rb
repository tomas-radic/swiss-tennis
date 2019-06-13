require 'rails_helper'

describe PlayerOpponentsUpToRoundQuery do
  subject(:described_query) { described_class.call(player: player, round: round24) }

  let!(:season) { create(:season) }
  let!(:previous_season) { create(:season) }
  let!(:player) { create(:player) }

  let!(:round11) { create(:round, season: previous_season) }
  let!(:round12) { create(:round, season: previous_season) }
  let!(:round13) { create(:round, season: previous_season) }
  let!(:round21) { create(:round, season: season) }
  let!(:round22) { create(:round, season: season) }
  let!(:round23) { create(:round, season: season) }
  let!(:round24) { create(:round, season: season) }

  let!(:match11) { create(:match, :finished, round: round11, player1: player) }
  let!(:match12) { create(:match, :finished, round: round12, player1: player) }
  let!(:match13) { create(:match, :finished, round: round13, player1: player) }
  let!(:match21) { create(:match, :finished ,round: round21, player1: player) }
  let!(:match22) { create(:match, round: round22, player1: player) }
  let!(:match23) { create(:match, :finished, round: round23, player2: player) }
  let!(:match24) { create(:match, :finished, round: round24, player1: player) }

  it 'Returns matches of given player up to given round in the season' do
    result = described_query

    expect(result.length).to eq 2
    expect(result).to include(match21.player2, match23.player1)
  end
end
