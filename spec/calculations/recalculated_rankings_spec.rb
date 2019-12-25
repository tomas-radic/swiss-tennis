require 'rails_helper'

describe RecalculatedRankings do
  subject(:calculation) { described_class.result_for(season: season) }

  let!(:season) { create(:season) }

  # Players
  let!(:playerA) { create(:player, first_name: 'Player', last_name: 'A') }
  let!(:playerB) { create(:player, first_name: 'Player', last_name: 'B') }
  let!(:playerC) { create(:player, first_name: 'Player', last_name: 'C') }
  let!(:playerD) { create(:player, first_name: 'Player', last_name: 'D') }
  let!(:playerE) { create(:player, first_name: 'Player', last_name: 'E') }
  let!(:playerF) { create(:player, first_name: 'Player', last_name: 'F') }

  # Rounds
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:round3) { create(:round, season: season) }
  let!(:round4) { create(:round, season: season) }

  # Rankings
  let!(:ranking_1_A) { create(:ranking, round: round1, player: playerA) }
  let!(:ranking_1_B) { create(:ranking, round: round1, player: playerB) }
  let!(:ranking_1_C) { create(:ranking, round: round1, player: playerC) }
  let!(:ranking_1_D) { create(:ranking, round: round1, player: playerD) }
  let!(:ranking_1_E) { create(:ranking, round: round1, player: playerE) }
  let!(:ranking_1_F) { create(:ranking, round: round1, player: playerF) }
  let!(:ranking_2_A) { create(:ranking, round: round2, player: playerA) }
  let!(:ranking_2_B) { create(:ranking, round: round2, player: playerB) }
  let!(:ranking_2_C) { create(:ranking, round: round2, player: playerC) }
  let!(:ranking_2_D) { create(:ranking, round: round2, player: playerD) }
  let!(:ranking_2_E) { create(:ranking, round: round2, player: playerE) }
  let!(:ranking_2_F) { create(:ranking, round: round2, player: playerF) }
  let!(:ranking_3_A) { create(:ranking, round: round3, player: playerA) }
  let!(:ranking_3_B) { create(:ranking, round: round3, player: playerB) }
  let!(:ranking_3_C) { create(:ranking, round: round3, player: playerC) }
  let!(:ranking_3_D) { create(:ranking, round: round3, player: playerD) }
  let!(:ranking_3_E) { create(:ranking, round: round3, player: playerE) }
  let!(:ranking_3_F) { create(:ranking, round: round3, player: playerF) }
  let!(:ranking_4_A) { create(:ranking, round: round4, player: playerA) }
  let!(:ranking_4_B) { create(:ranking, round: round4, player: playerB) }
  let!(:ranking_4_C) { create(:ranking, round: round4, player: playerC) }
  let!(:ranking_4_D) { create(:ranking, round: round4, player: playerD) }
  let!(:ranking_4_E) { create(:ranking, round: round4, player: playerE) }
  let!(:ranking_4_F) { create(:ranking, round: round4, player: playerF) }

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
                             winner: playerC, looser: playerF,
                             set1_player1_score: nil, set1_player2_score: nil,
                             set2_player1_score: nil, set2_player2_score: nil,
                             set3_player1_score: nil, set3_player2_score: nil) }

  before do
    round1.insert_at(1)
    round2.insert_at(2)
    round3.insert_at(3)
    round4.insert_at(4)
  end

  it 'Returns array of hashes containing expected values of all rankings of given season' do
    result = calculation

    # 1st round rankings

    # PlayerA handicap:
    #   all points PlayerB has in round1  => 0
    expect(result.find { |r| r[:id] == ranking_1_A.id }).to include(
                                                             round_id: round1.id,
                                                             player_id: playerA.id,
                                                             player_name: playerA.name,
                                                             points: 3,
                                                             toss_points: 3,
                                                             handicap: 0,
                                                             sets_difference: 2,
                                                             games_difference: 12,
                                                             relevant: true
                                                         )

    # PlayerB handicap:
    #   no points of PlayerA - refused to play in 1st round   => 0
    expect(result.find { |r| r[:id] == ranking_1_B.id }).to include(
                                                             round_id: round1.id,
                                                             player_id: playerB.id,
                                                             player_name: playerB.name,
                                                             points: 0,
                                                             toss_points: 0,
                                                             handicap: 0,
                                                             sets_difference: -2,
                                                             games_difference: -12,
                                                             relevant: false
                                                         )

    # PlayerC handicap:
    #   all points PlayerD has in round1  => 1
    expect(result.find { |r| r[:id] == ranking_1_C.id }).to include(
                                                             round_id: round1.id,
                                                             player_id: playerC.id,
                                                             player_name: playerC.name,
                                                             points: 2,
                                                             toss_points: 2,
                                                             handicap: 1,
                                                             sets_difference: 1,
                                                             games_difference: 1,
                                                             relevant: true
                                                         )

    # PlayerD handicap:
    #   all points PlayerC has in round1  => 2
    expect(result.find { |r| r[:id] == ranking_1_D.id }).to include(
                                                             round_id: round1.id,
                                                             player_id: playerD.id,
                                                             player_name: playerD.name,
                                                             points: 1,
                                                             toss_points: 1,
                                                             handicap: 2,
                                                             sets_difference: -1,
                                                             games_difference: -1,
                                                             relevant: true
                                                         )

    # PlayerE handicap:
    #   all points PlayerF has in round1  => 3
    expect(result.find { |r| r[:id] == ranking_1_E.id }).to include(
                                                             round_id: round1.id,
                                                             player_id: playerE.id,
                                                             player_name: playerE.name,
                                                             points: 0,
                                                             toss_points: 0,
                                                             handicap: 3,
                                                             sets_difference: -2,
                                                             games_difference: -8,
                                                             relevant: true
                                                         )

    # PlayerF handicap:
    #   all points PlayerE has in round1  => 0
    expect(result.find { |r| r[:id] == ranking_1_F.id }).to include(
                                                             round_id: round1.id,
                                                             player_id: playerF.id,
                                                             player_name: playerF.name,
                                                             points: 3,
                                                             toss_points: 3,
                                                             handicap: 0,
                                                             sets_difference: 2,
                                                             games_difference: 8,
                                                             relevant: true
                                                         )

    # 2nd round rankings

    # PlayerA handicap:
    #   all points PlayerB has in round1        => 0
    #   + all points PlayerC has in round2      => 2 (2 + 0)
    #   + round2 earned points of PlayerB       => 1
    expect(result.find { |r| r[:id] == ranking_2_A.id }).to include(
                                                             round_id: round2.id,
                                                             player_id: playerA.id,
                                                             player_name: playerA.name,
                                                             points: 3 + 3,
                                                             toss_points: 6,
                                                             handicap: 0 + 2 + 1,
                                                             sets_difference: 2 + 2,
                                                             games_difference: 12 + 3,
                                                             relevant: true
                                                         )

    # PlayerB handicap:
    #   no points of PlayerA - refused to play 1st round                      => 0
    #   + all points PlayerE has in round2                                    => 2 (0 + 2)
    #   + no round2 earned points of PlayerA - refused to play in 1st round   => 0
    expect(result.find { |r| r[:id] == ranking_2_B.id }).to include(
                                                             round_id: round2.id,
                                                             player_id: playerB.id,
                                                             player_name: playerB.name,
                                                             points: 0 + 1,
                                                             toss_points: 1,
                                                             handicap: 0 + 2 + 0,
                                                             sets_difference: -2 - 1,
                                                             games_difference: -12 + 5,
                                                             relevant: true
                                                         )

    # PlayerC handicap:
    #   all points PlayerD has in round1        => 1
    #   + all points PlayerA has in round2      => 6 (3 + 3)
    #   + round2 earned points of PlayerD       => 2
    expect(result.find { |r| r[:id] == ranking_2_C.id }).to include(
                                                             round_id: round2.id,
                                                             player_id: playerC.id,
                                                             player_name: playerC.name,
                                                             points: 2 + 0,
                                                             toss_points: 2,
                                                             handicap: 1 + 6 + 2,
                                                             sets_difference: 1 - 2,
                                                             games_difference: 1 - 3,
                                                             relevant: true
                                                         )

    # PlayerD handicap:
    #   all points PlayerC has in round1        => 2
    #   + all points PlayerF has in round2      => 4 (3 + 1)
    #   + round2 earned points of PlayerC       => 0
    expect(result.find { |r| r[:id] == ranking_2_D.id }).to include(
                                                             round_id: round2.id,
                                                             player_id: playerD.id,
                                                             player_name: playerD.name,
                                                             points: 1 + 2,
                                                             toss_points: 3,
                                                             handicap: 2 + 4 + 0,
                                                             sets_difference: -1 + 1,
                                                             games_difference: -1 + 8,
                                                             relevant: true
                                                         )

    # PlayerE handicap:
    #   all points PlayerF has in round1        => 3
    #   + all points PlayerB has in round2      => 1 (0 + 1)
    #   + round2 earned points of PlayerF       => 1
    expect(result.find { |r| r[:id] == ranking_2_E.id }).to include(
                                                             round_id: round2.id,
                                                             player_id: playerE.id,
                                                             player_name: playerE.name,
                                                             points: 0 + 2,
                                                             toss_points: 2,
                                                             handicap: 3 + 1 + 1,
                                                             sets_difference: -2 + 1,
                                                             games_difference: -8 - 5,
                                                             relevant: true
                                                         )

    # PlayerF handicap:
    #   all points PlayerE has in round1      => 0
    #   + all points PlayerD has in round2    => 3 (1 + 2)
    #   + round2 earned points of PlayerE     => 2
    expect(result.find { |r| r[:id] == ranking_2_F.id }).to include(
                                                             round_id: round2.id,
                                                             player_id: playerF.id,
                                                             player_name: playerF.name,
                                                             points: 3 + 1,
                                                             toss_points: 4,
                                                             handicap: 0 + 3 + 2,
                                                             sets_difference: 2 - 1,
                                                             games_difference: 8 - 8,
                                                             relevant: true
                                                         )

    # 3rd round rankings

    # PlayerA handicap:
    #   all points PlayerB has in round1
    #   + all points PlayerC has in round2
    #   + round2 earned points of PlayerB
    #   + all points PlayerD has in round3
    #   + round3 earned points of PlayerC
    #   + round3 earned points of PlayerB
    expect(result.find { |r| r[:id] == ranking_3_A.id }).to include(
                                                             round_id: round3.id,
                                                             player_id: playerA.id,
                                                             player_name: playerA.name,
                                                             points: 3 + 3 + 3,
                                                             toss_points: 9,
                                                             handicap: (0) + (2 + 1) + (3 + 1 + 0),
                                                             sets_difference: 2 + 2 + 2,
                                                             games_difference: 12 + 3 + 7,
                                                             relevant: true
                                                         )

    # PlayerB handicap:
    #   no points of PlayerA - refused to play 1st round
    #   + all points PlayerE has in round2
    #   + no round2 earned points of PlayerA - refused to play in 1st round
    #   + no points PlayerF has in round3, the match has not been yet played
    #   + round3 earned points of PlayerE
    #   + no round3 points of PlayerA - refused to play in 1st round
    expect(result.find { |r| r[:id] == ranking_3_B.id }).to include(
                                                             round_id: round3.id,
                                                             player_id: playerB.id,
                                                             player_name: playerB.name,
                                                             points: 0 + 1 + 0,
                                                             toss_points: 1,
                                                             handicap: (0) + (2) + (0 + 2),
                                                             sets_difference: -2 - 1 + 0,
                                                             games_difference: -12 + 5 + 0,
                                                             relevant: true
                                                         )

    # PlayerC handicap:
    #   all points PlayerD has in round1
    #   + all points PlayerA has in round2
    #   + round2 earned points of PlayerD
    #   + all points PlayerE has in round3
    #   + round3 earned points of PlayerA
    #   + round3 earned points of PlayerD
    expect(result.find { |r| r[:id] == ranking_3_C.id }).to include(
                                                             round_id: round3.id,
                                                             player_id: playerC.id,
                                                             player_name: playerC.name,
                                                             points: 2 + 0 + 1,
                                                             toss_points: 3,
                                                             handicap: (1) + (6 + 2) + (4 + 3 + 0),
                                                             sets_difference: 1 - 2 - 1,
                                                             games_difference: 1 - 3 - 2,
                                                             relevant: true
                                                         )

    # PlayerD handicap:
    #   all points PlayerC has in round1
    #   + all points PlayerF has in round2
    #   + round2 earned points of PlayerC
    #   + all points PlayerA has in round3
    #   + round3 earned points of PlayerF
    #   + round3 earned points of PlayerC
    expect(result.find { |r| r[:id] == ranking_3_D.id }).to include(
                                                             round_id: round3.id,
                                                             player_id: playerD.id,
                                                             player_name: playerD.name,
                                                             points: 1 + 2 + 0,
                                                             toss_points: 3,
                                                             handicap: (2) + (4 + 0) + (9 + 0 + 1),
                                                             sets_difference: -1 + 1 - 2,
                                                             games_difference: -1 + 8 - 7,
                                                             relevant: true
                                                         )

    # PlayerE handicap:
    #   all points PlayerF has in round1
    #   + all points PlayerB has in round2
    #   + round2 earned points of PlayerF
    #   + all points PlayerC has in round3
    #   + round3 earned points of PlayerB
    #   + round3 earned points of PlayerF
    expect(result.find { |r| r[:id] == ranking_3_E.id }).to include(
                                                             round_id: round3.id,
                                                             player_id: playerE.id,
                                                             player_name: playerE.name,
                                                             points: 0 + 2 + 2,
                                                             toss_points: 4,
                                                             handicap: (3) + (1 + 1) + (3 + 0 + 0),
                                                             sets_difference: -2 + 1 + 1,
                                                             games_difference: -8 - 5 + 2,
                                                             relevant: true
                                                         )

    # PlayerF handicap:
    #   all points PlayerE has in round1                                            => 0
    #   + all points PlayerD has in round2                                          => 3 (1 + 2)
    #   + round2 earned points of PlayerE                                           => 2
    #   + no points PlayerB has in round3 since the match has not yet been played   => 0
    #   + round3 earned points of PlayerD                                           => 0
    #   + round3 earned points of PlayerE                                           => 2
    expect(result.find { |r| r[:id] == ranking_3_F.id }).to include(
                                                             round_id: round3.id,
                                                             player_id: playerF.id,
                                                             player_name: playerF.name,
                                                             points: 3 + 1 + 0,
                                                             toss_points: 4,
                                                             handicap: 0 + 3 + 2 + 0 + 0 + 2,
                                                             sets_difference: 2 - 1 + 0,
                                                             games_difference: 8 - 8 + 0,
                                                             relevant: true
                                                         )

    # 4th round rankings

    # PlayerA handicap:
    #   all points PlayerB has in round1
    #   + all points PlayerC has in round2
    #   + round2 earned points of PlayerB
    #   + all points PlayerD has in round3
    #   + round3 earned points of PlayerC
    #   + round3 earned points of PlayerB
    #   + no points of PlayerE since the round4 match has not yet been played
    #   + round4 earned points of PlayerD
    #   + round4 earned points of PlayerC
    #   + round4 earned points of PlayerB
    expect(result.find { |r| r[:id] == ranking_4_A.id }).to include(
                                                             round_id: round4.id,
                                                             player_id: playerA.id,
                                                             player_name: playerA.name,
                                                             points: 3 + 3 + 3 + 0,
                                                             toss_points: 9,
                                                             handicap: (0) + (2 + 1) + (3 + 1 + 0) + (0 + 0 + 3),
                                                             sets_difference: 2 + 2 + 2 + 0,
                                                             games_difference: 12 + 3 + 7 + 0,
                                                             relevant: true
                                                         )

    # PlayerB handicap:
    #   no points of PlayerA - refused to play 1st round                      => 0
    #   + all points PlayerE has in round2                                    => 2 (0 + 2)
    #   + no round2 earned points of PlayerA - refused to play in 1st round   => 0
    #   + no points PlayerF has in round3 - the match has not yet been played => 0
    #   + round3 earned points of PlayerE                                     => 2
    #   + no round3 earned points of PlayerA - refused to play in 1st round   => 0
    #   + all points PlayerD has in round4                                    => 3 (1 + 2 + 0 + 0)
    #   + no round4 earned points of PlayerF - their match is not finished    => 0
    #   + round4 earned points of PlayerE                                     => 0
    #   + no round4 earned points of PlayerA - refused to play in 1st round   => 0
    expect(result.find { |r| r[:id] == ranking_4_B.id }).to include(
                                                             round_id: round4.id,
                                                             player_id: playerB.id,
                                                             player_name: playerB.name,
                                                             points: 0 + 1 + 0 + 3,
                                                             toss_points: 4,
                                                             handicap: 0 + 2 + 0 + 0 + 2 + 0 + 3 + 0 + 0 + 0,
                                                             sets_difference: -2 - 1 + 0 + 2,
                                                             games_difference: -12 + 5 + 0 + 4,
                                                             relevant: true
                                                         )

    # PlayerC handicap:
    #   all points PlayerD has in round1
    #   + all points PlayerA has in round2
    #   + round2 earned points of PlayerD
    #   + all points PlayerE has in round3
    #   + round3 earned points of PlayerA
    #   + round3 earned points of PlayerD
    #   + no points PlayerF has in round4 since the match has not yet been played
    #   + round4 earned points of PlayerE
    #   + round4 earned points of PlayerA
    #   + round4 earned points of PlayerD
    expect(result.find { |r| r[:id] == ranking_4_C.id }).to include(
                                                             round_id: round4.id,
                                                             player_id: playerC.id,
                                                             player_name: playerC.name,
                                                             points: 2 + 0 + 1 + 0,
                                                             toss_points: 3,
                                                             handicap: (1) + (6 + 2) + (4 + 3 + 0) + (0 + 0 + 0 + 0),
                                                             sets_difference: 1 - 2 - 1 + 0,
                                                             games_difference: 1 - 3 - 2 + 0,
                                                             relevant: true
                                                         )

    # PlayerD handicap:
    #   all points PlayerC has in round1
    #   + all points PlayerF has in round2
    #   + round2 earned points of PlayerC
    #   + all points PlayerA has in round3
    #   + round3 earned points of PlayerF
    #   + round3 earned points of PlayerC
    #   + all points PlayerB has in round4
    #   + round4 earned points of PlayerA
    #   + round4 earned points of PlayerF
    #   + round4 earned points of PlayerC
    expect(result.find { |r| r[:id] == ranking_4_D.id }).to include(
                                                             round_id: round4.id,
                                                             player_id: playerD.id,
                                                             player_name: playerD.name,
                                                             points: 1 + 2 + 0 + 0,
                                                             toss_points: 3,
                                                             handicap: (2) + (4 + 0) + (9 + 0 + 1) + (4 + 0 + 0 + 0),
                                                             sets_difference: -1 + 1 - 2 - 2,
                                                             games_difference: -1 + 8 - 7 - 4,
                                                             relevant: true
                                                         )

    # PlayerE handicap:
    #   all points PlayerF has in round1
    #   + all points PlayerB has in round2
    #   + round2 earned points of PlayerF
    #   + all points PlayerC has in round3
    #   + round3 earned points of PlayerB
    #   + round3 earned points of PlayerF
    #   + no points PlayerA has in round4 since the match has not yet been played
    #   + round4 earned points of PlayerC
    #   + round4 earned points of PlayerB
    #   + round4 earned points of PlayerF
    expect(result.find { |r| r[:id] == ranking_4_E.id }).to include(
                                                             round_id: round4.id,
                                                             player_id: playerE.id,
                                                             player_name: playerE.name,
                                                             points: 0 + 2 + 2 + 0,
                                                             toss_points: 4,
                                                             handicap: (3) + (1 + 1) + (3 + 0 + 0) + (0 + 0 + 3 + 0),
                                                             sets_difference: -2 + 1 + 1 + 0,
                                                             games_difference: -8 - 5 + 2 + 0,
                                                             relevant: true
                                                         )

    # PlayerF handicap:
    #   all points PlayerE has in round1                                            => 0
    #   + all points PlayerD has in round2                                          => 3 (1 + 2)
    #   + round2 earned points of PlayerE                                           => 2
    #   + no points PlayerB has in round3 since the match has not yet been played   => 0
    #   + round3 earned points of PlayerD                                           => 0
    #   + round3 earned points of PlayerE                                           => 2
    #   + no points of PlayerC - the match has not yet been played                  => 0
    #   + round4 earned points of PlayerD                                           => 0
    #   + round4 earned points of PlayerE                                           => 0
    expect(result.find { |r| r[:id] == ranking_4_F.id }).to include(
                                                             round_id: round4.id,
                                                             player_id: playerF.id,
                                                             player_name: playerF.name,
                                                             points: 3 + 1 + 0 + 0,
                                                             toss_points: 4,
                                                             handicap: 0 + 3 + 2 + 0 + 0 + 2 + 0 + 0 + 0,
                                                             sets_difference: 2 - 1 + 0 + 0,
                                                             games_difference: 8 - 8 + 0 + 0,
                                                             relevant: true
                                                         )
  end

  context 'When there is previous season existing' do
    let!(:previous_season) { create(:season) }
    let!(:ps_round1) { create(:round, season: previous_season) }
    let!(:ranking_in_ps_round1) { create(:ranking, round: ps_round1, player: playerA) }

    it 'Returns hash NOT containing data from another season' do
      result = calculation

      expect(result.find { |r| r[:id] == ranking_in_ps_round1.id }).to be_nil
    end
  end
end
