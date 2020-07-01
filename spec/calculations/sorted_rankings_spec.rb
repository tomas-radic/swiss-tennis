require "rails_helper"

describe SortedRankings do
  subject(:calculation) { described_class.result_for(round: round) }

  let!(:season) { create(:season) }

  # Players
  let!(:playerA) { create(:player, first_name: 'Player', last_name: 'A', seasons: [season]) }
  let!(:playerB) { create(:player, first_name: 'Player', last_name: 'B', seasons: [season]) }
  let!(:playerC) { create(:player, first_name: 'Player', last_name: 'C', seasons: [season]) }
  let!(:playerD) { create(:player, first_name: 'Player', last_name: 'D', seasons: [season]) }
  let!(:playerE) { create(:player, first_name: 'Player', last_name: 'E', seasons: [season]) }
  let!(:playerF) { create(:player, first_name: 'Player', last_name: 'F', seasons: [season]) }

  # Rounds
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:round3) { create(:round, season: season) }
  let!(:round4) { create(:round, season: season) }

  # Rankings
  let!(:ranking_1_A) { create(:ranking, round: round1, player: playerA, relevant: true, points: 3, sets_difference: 2, games_difference: 12) }
  let!(:ranking_1_B) { create(:ranking, round: round1, player: playerB, relevant: false, points: 0, sets_difference: -2, games_difference: -12) }
  let!(:ranking_1_C) { create(:ranking, round: round1, player: playerC, relevant: true, points: 2, sets_difference: 1, games_difference: 1) }
  let!(:ranking_1_D) { create(:ranking, round: round1, player: playerD, relevant: true, points: 1, sets_difference: -1, games_difference: -1) }
  let!(:ranking_1_E) { create(:ranking, round: round1, player: playerE, relevant: true, points: 0, sets_difference: -2, games_difference: -8) }
  let!(:ranking_1_F) { create(:ranking, round: round1, player: playerF, relevant: true, points: 3, sets_difference: 2, games_difference: 8) }
  let!(:ranking_2_A) { create(:ranking, round: round2, player: playerA, relevant: true, points: 6, sets_difference: 4, games_difference: 15) }
  let!(:ranking_2_B) { create(:ranking, round: round2, player: playerB, relevant: true, points: 1, sets_difference: -1, games_difference: -7) }
  let!(:ranking_2_C) { create(:ranking, round: round2, player: playerC, relevant: true, points: 2, sets_difference: -1, games_difference: -2) }
  let!(:ranking_2_D) { create(:ranking, round: round2, player: playerD, relevant: true, points: 3, sets_difference: 0, games_difference: 7) }
  let!(:ranking_2_E) { create(:ranking, round: round2, player: playerE, relevant: true, points: 2, sets_difference: -3, games_difference: -13) }
  let!(:ranking_2_F) { create(:ranking, round: round2, player: playerF, relevant: true, points: 4, sets_difference: 1, games_difference: 0) }
  let!(:ranking_3_A) { create(:ranking, round: round3, player: playerA, relevant: true, points: 9, sets_difference: 6, games_difference: 22) }
  let!(:ranking_3_B) { create(:ranking, round: round3, player: playerB, relevant: true, points: 1, sets_difference: -1, games_difference: -7) }
  let!(:ranking_3_C) { create(:ranking, round: round3, player: playerC, relevant: true, points: 3, sets_difference: -2, games_difference: -4) }
  let!(:ranking_3_D) { create(:ranking, round: round3, player: playerD, relevant: true, points: 3, sets_difference: -2, games_difference: 0) }
  let!(:ranking_3_E) { create(:ranking, round: round3, player: playerE, relevant: true, points: 4, sets_difference: -2, games_difference: -11) }
  let!(:ranking_3_F) { create(:ranking, round: round3, player: playerF, relevant: true, points: 4, sets_difference: 1, games_difference: 0) }
  let!(:ranking_4_A) { create(:ranking, round: round4, player: playerA, relevant: true, points: 9, sets_difference: 6, games_difference: 22) }
  let!(:ranking_4_B) { create(:ranking, round: round4, player: playerB, relevant: true, points: 4, sets_difference: 1, games_difference: -3) }
  let!(:ranking_4_C) { create(:ranking, round: round4, player: playerC, relevant: true, points: 3, sets_difference: -2, games_difference: -4) }
  let!(:ranking_4_D) { create(:ranking, round: round4, player: playerD, relevant: true, points: 3, sets_difference: -4, games_difference: -4) }
  let!(:ranking_4_E) { create(:ranking, round: round4, player: playerE, relevant: true, points: 4, sets_difference: -2, games_difference: -11) }
  let!(:ranking_4_F) { create(:ranking, round: round4, player: playerF, relevant: true, points: 4, sets_difference: 1, games_difference: 0) }

  # 1st round matches
  let!(:match_1_AB) { create(:match, :finished, round: round1, player1: playerA, player2: playerB, players: [playerA, playerB],
                             retired_player: playerB, winner: playerA, looser: playerB,
                             set1_player1_score: nil, set1_player2_score: nil,
                             set2_player1_score: nil, set2_player2_score: nil,
                             set3_player1_score: nil, set3_player2_score: nil) }

  let!(:match_1_CD) { create(:match, :finished, round: round1, player1: playerC, player2: playerD, players: [playerC, playerD],
                             winner: playerC, looser: playerD,
                             set1_player1_score: 6, set1_player2_score: 4,
                             set2_player1_score: 3, set2_player2_score: 6,
                             set3_player1_score: 6, set3_player2_score: 4) }

  let!(:match_1_EF) { create(:match, :finished, round: round1, player1: playerE, player2: playerF, players: [playerE, playerF],
                             winner: playerF, looser: playerE,
                             set1_player1_score: 4, set1_player2_score: 6,
                             set2_player1_score: 0, set2_player2_score: 6,
                             set3_player1_score: nil, set3_player2_score: nil) }

  # 2nd round matches
  let!(:match_2_AC) { create(:match, :finished, round: round2, player1: playerA, player2: playerC, players: [playerA, playerC],
                             winner: playerA, looser: playerC,
                             set1_player1_score: 6, set1_player2_score: 4,
                             set2_player1_score: 7, set2_player2_score: 6) }

  let!(:match_2_BE) { create(:match, :finished, round: round2, player1: playerB, player2: playerE, players: [playerB, playerE],
                             retired_player: playerB, winner: playerE, looser: playerB,
                             set1_player1_score: 6, set1_player2_score: 1,
                             set2_player1_score: 1, set2_player2_score: 1,
                             set3_player1_score: nil, set3_player2_score: nil) }

  let!(:match_2_DF) { create(:match, :finished, round: round2, player1: playerD, player2: playerF, players: [playerD, playerF],
                             winner: playerD, looser: playerF,
                             set1_player1_score: 6, set1_player2_score: 1,
                             set2_player1_score: 4, set2_player2_score: 6,
                             set3_player1_score: 6, set3_player2_score: 1) }

  # 3rd round matches
  let!(:match_3_AD) { create(:match, :finished, round: round3, player1: playerA, player2: playerD, players: [playerA, playerD],
                             winner: playerA, looser: playerD,
                             set1_player1_score: 6, set1_player2_score: 2,
                             set2_player1_score: 6, set2_player2_score: 3,
                             set3_player1_score: nil, set3_player2_score: nil) }

  let!(:match_3_BF) { create(:match, round: round3, player1: playerB, player2: playerF, players: [playerB, playerF],
                             set1_player1_score: nil, set1_player2_score: nil,
                             set2_player1_score: nil, set2_player2_score: nil,
                             set3_player1_score: nil, set3_player2_score: nil) }

  let!(:match_3_CE) { create(:match, :finished, round: round3, player1: playerC, player2: playerE, players: [playerC, playerE],
                             winner: playerE, looser: playerC,
                             set1_player1_score: 6, set1_player2_score: 4,
                             set2_player1_score: 3, set2_player2_score: 6,
                             set3_player1_score: 6, set3_player2_score: 7) }

  # 4th round matches
  let!(:match_4_AE) { create(:match, round: round4, player1: playerA, player2: playerE, players: [playerA, playerE],
                             set1_player1_score: nil, set1_player2_score: nil,
                             set2_player1_score: nil, set2_player2_score: nil,
                             set3_player1_score: nil, set3_player2_score: nil) }

  let!(:match_4_BD) { create(:match, :finished, round: round4, player1: playerB, player2: playerD, players: [playerB, playerD],
                             winner: playerB, looser: playerD,
                             set1_player1_score: 6, set1_player2_score: 4,
                             set2_player1_score: 6, set2_player2_score: 4,
                             set3_player1_score: nil, set3_player2_score: nil) }

  let!(:match_4_CF) { create(:match, round: round4, player1: playerC, player2: playerF, players: [playerC, playerF],
                             set1_player1_score: nil, set1_player2_score: nil,
                             set2_player1_score: nil, set2_player2_score: nil,
                             set3_player1_score: nil, set3_player2_score: nil) }

  before do
    round1.insert_at(1)
    round2.insert_at(2)
    round3.insert_at(3)
    round4.insert_at(4)
  end

  context "With round 1" do
    let(:round) { round1 }

    it "Returns sorted rankings (as hashes)" do
      result = calculation

      expect(result[0]).to include(
                               player: playerA,
                               relevant: 1,
                               points: 3,
                               handicap: 0,
                               sets_difference: 2,
                               games_difference: 12
                           )

      expect(result[1]).to include(
                               player: playerF,
                               relevant: 1,
                               points: 3,
                               handicap: 0,
                               sets_difference: 2,
                               games_difference: 8
                           )

      expect(result[2]).to include(
                               player: playerC,
                               relevant: 1,
                               points: 2,
                               handicap: 1,
                               sets_difference: 1,
                               games_difference: 1
                           )

      expect(result[3]).to include(
                               player: playerD,
                               relevant: 1,
                               points: 1,
                               handicap: 2,
                               sets_difference: -1,
                               games_difference: -1
                           )

      expect(result[4]).to include(
                               player: playerE,
                               relevant: 1,
                               points: 0,
                               handicap: 3,
                               sets_difference: -2,
                               games_difference: -8
                           )

      expect(result[5]).to include(
                               player: playerB,
                               relevant: 0,
                               points: 0,
                               handicap: 0,
                               sets_difference: -2,
                               games_difference: -12
                           )
    end
  end

  context "With round 2" do
    let(:round) { round2 }

    it "Returns sorted rankings (as hashes)" do
      result = calculation

      expect(result[0]).to include(
                               player: playerA,
                               relevant: 1,
                               points: 6,
                               handicap: 3,
                               sets_difference: 4,
                               games_difference: 15
                           )

      expect(result[1]).to include(
                               player: playerF,
                               relevant: 1,
                               points: 4,
                               handicap: 5,
                               sets_difference: 1,
                               games_difference: 0
                           )

      expect(result[2]).to include(
                               player: playerD,
                               relevant: 1,
                               points: 3,
                               handicap: 6,
                               sets_difference: 0,
                               games_difference: 7
                           )

      expect(result[3]).to include(
                               player: playerC,
                               relevant: 1,
                               points: 2,
                               handicap: 9,
                               sets_difference: -1,
                               games_difference: -2
                           )

      expect(result[4]).to include(
                               player: playerE,
                               relevant: 1,
                               points: 2,
                               handicap: 5,
                               sets_difference: -3,
                               games_difference: -13
                           )

      expect(result[5]).to include(
                               player: playerB,
                               relevant: 1,
                               points: 1,
                               handicap: 2,
                               sets_difference: -1,
                               games_difference: -7
                           )
    end
  end

  context "With round 3" do
    let(:round) { round3 }

    it "Returns sorted rankings (as hashes)" do
      result = calculation

      expect(result[0]).to include(
                               player: playerA,
                               relevant: 1,
                               points: 9,
                               handicap: 7,
                               sets_difference: 6,
                               games_difference: 22
                           )

      expect(result[1]).to include(
                               player: playerE,
                               relevant: 1,
                               points: 4,
                               handicap: 8,
                               sets_difference: -2,
                               games_difference: -11
                           )

      expect(result[2]).to include(
                               player: playerF,
                               relevant: 1,
                               points: 4,
                               handicap: 7,
                               sets_difference: 1,
                               games_difference: 0
                           )

      expect(result[3]).to include(
                               player: playerD,
                               relevant: 1,
                               points: 3,
                               handicap: 16,
                               sets_difference: -2,
                               games_difference: 0
                           )

      expect(result[4]).to include(
                               player: playerC,
                               relevant: 1,
                               points: 3,
                               handicap: 16,
                               sets_difference: -2,
                               games_difference: -4
                           )

      expect(result[5]).to include(
                               player: playerB,
                               relevant: 1,
                               points: 1,
                               handicap: 4,
                               sets_difference: -1,
                               games_difference: -7
                           )
    end
  end

  context "With round 4" do
    let(:round) { round4 }

    it "Returns sorted rankings (as hashes)" do
      result = calculation

      expect(result[0]).to include(
                               player: playerA,
                               relevant: 1,
                               points: 9,
                               handicap: 10,
                               sets_difference: 6,
                               games_difference: 22
                           )

      expect(result[1]).to include(
                               player: playerE,
                               relevant: 1,
                               points: 4,
                               handicap: 11,
                               sets_difference: -2,
                               games_difference: -11
                           )

      expect(result[2]).to include(
                               player: playerF,
                               relevant: 1,
                               points: 4,
                               handicap: 7,
                               sets_difference: 1,
                               games_difference: 0
                           )

      expect(result[3]).to include(
                               player: playerB,
                               relevant: 1,
                               points: 4,
                               handicap: 7,
                               sets_difference: 1,
                               games_difference: -3
                           )

      expect(result[4]).to include(
                               player: playerD,
                               relevant: 1,
                               points: 3,
                               handicap: 20,
                               sets_difference: -4,
                               games_difference: -4
                           )

      expect(result[5]).to include(
                               player: playerC,
                               relevant: 1,
                               points: 3,
                               handicap: 16,
                               sets_difference: -2,
                               games_difference: -4
                           )
    end
  end
end
