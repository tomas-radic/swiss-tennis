require 'rails_helper'

describe SuccessOfPlay do
  subject(:calculation_result) { described_class.result_for player: player, season: season }

  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:round3) { create(:round, season: season) }

  context 'With player assigned to some matches' do
    let!(:match1) { create(:match, :finished, round: round1, player2: player, set1_player1_score: 4, set1_player2_score: 6, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }
    let!(:match2) { create(:match, :finished, round: round2, player1: player, set1_player1_score: 6, set1_player2_score: 2, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }
    let!(:match3) { create(:match, round: round3, player2: player) }

    let!(:player) { create(:player, seasons: [season]) }

    it 'Returns calculated success of play' do
      result = calculation_result

      expect(result).to be_a Hash
      expect(result).to include(won_games: 12, all_games: 18, percentage: 66, season: season)
    end
  end


  context 'With player not assigned to any matches' do
    let!(:player) { create(:player) }

    it 'Returns zeros' do
      result = calculation_result

      expect(result).to be_a Hash
      expect(result).to include(won_games: 0, all_games: 0, percentage: 0, season: season)
    end
  end
end
