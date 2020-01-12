require 'rails_helper'

describe SuccessOfPlay do
  subject(:calculation_result) { described_class.result_for player: player, season: current_season }

  let!(:current_season) { create(:season) }
  let!(:cs_round1) { create(:round, season: current_season) }
  let!(:cs_round2) { create(:round, season: current_season) }
  let!(:cs_round3) { create(:round, season: current_season) }

  let!(:previous_season) { create(:season) }
  let!(:ps_round1) { create(:round, season: previous_season) }
  let!(:ps_round2) { create(:round, season: previous_season) }

  context 'With player assigned to matches in current and previous season' do
    let!(:cs_match1) { create(:match, :finished, round: cs_round1, player2: player, set1_player1_score: 4, set1_player2_score: 6, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }
    let!(:cs_match2) { create(:match, :finished, round: cs_round2, player1: player, set1_player1_score: 6, set1_player2_score: 2, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }
    let!(:cs_match3) { create(:match, round: cs_round3, player2: player) }

    let!(:ps_match1) { create(:match, :finished, round: ps_round1, player1: player, set1_player1_score: 7, set1_player2_score: 5, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }
    let!(:ps_match2) { create(:match, :finished, round: ps_round2, player2: player, set1_player1_score: 6, set1_player2_score: 3, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }

    let!(:player) { create(:player,
                           seasons: [previous_season, current_season]) }

    it 'Returns calculated success of play in history and in season' do
      result = calculation_result

      expect(result).to include(
                            {
                                history: (22 * 100.0 / 39).round,
                                season: (12 * 100.0 / 18).round
                            }
                        )
    end
  end

  context 'With player assigned to matches in previous season only' do
    let!(:ps_match1) { create(:match, :finished, round: ps_round1, player1: player, set1_player1_score: 7, set1_player2_score: 5, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }
    let!(:ps_match2) { create(:match, :finished, round: ps_round2, player2: player, set1_player1_score: 6, set1_player2_score: 3, set2_player1_score: nil, set2_player2_score: nil, set3_player1_score: nil, set3_player2_score: nil) }

    let!(:player) { create(:player,
                           seasons: [previous_season, current_season]) }

    it 'Returns calculated success of play in history only' do
      result = calculation_result

      expect(result).to include(
                            {
                                history: (10 * 100.0 / 21).round,
                                season: nil
                            }
                        )
    end
  end

  context 'With player not assigned to any matches' do
    let!(:player) { create(:player,
                           seasons: [previous_season, current_season]) }
    it 'Returns nils' do
      result = calculation_result

      expect(result).to include(
                            {
                                history: nil,
                                season: nil
                            }
                        )
    end
  end
end
