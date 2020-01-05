require 'rails_helper'

describe AllPlayersMatchesCountsAsPlayer1 do
  subject(:service) { described_class.call(season) }

  let!(:player1) { create(:player, seasons: [previous_season, season]) }
  let!(:player2) { create(:player, seasons: [previous_season, season]) }
  let!(:player3) { create(:player, seasons: [previous_season, season]) }

  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:match11) { create(:match, round: round1, player1: player1, player2: player2, players: [player1, player2]) }
  let!(:match12) { create(:match, round: round2, player1: player3, player2: player1, players: [player3, player1]) }
  let!(:match13) { create(:match, round: round2, player1: player1, player2: player3, players: [player1, player3]) }

  let!(:previous_season) { create(:season) }
  let!(:ps_round1) { create(:round, season: previous_season) }
  let!(:ps_round2) { create(:round, season: previous_season) }
  let!(:ps_match11) { create(:match, round: ps_round1, player1: player1, player2: player2, players: [player1, player2]) }
  let!(:ps_match12) { create(:match, round: ps_round2, player1: player3, player2: player1, players: [player3, player1]) }
  let!(:ps_match13) { create(:match, round: ps_round2, player1: player2, player2: player1, players: [player1, player3]) }

  it 'Returns player ids with counts how many times they were as player1 in a match in given season' do
    result = service.result

    expect(result).to include(
      player1.id => 2,
      player3.id => 1
    )
  end
end
