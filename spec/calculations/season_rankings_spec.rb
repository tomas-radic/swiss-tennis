require 'rails_helper'

describe SeasonRankings do
  subject(:calculation) { described_class.result_for(season: season) }

  let!(:season) { create(:season) }

  # Players
  let!(:player1) { create(:player, first_name: 'Player', last_name: '1') }
  let!(:player2) { create(:player, first_name: 'Player', last_name: '2') }
  let!(:player3) { create(:player, first_name: 'Player', last_name: '3') }
  let!(:player4) { create(:player, first_name: 'Player', last_name: '4') }
  let!(:player5) { create(:player, first_name: 'Player', last_name: '5') }
  let!(:player6) { create(:player, first_name: 'Player', last_name: '6') }
  let!(:player7) { create(:player, first_name: 'Player', last_name: '7') }
  let!(:player8) { create(:player, first_name: 'Player', last_name: '8') }

  # Rounds
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:round3) { create(:round, season: season) }

  # Rankings
  let!(:ranking_1_1) { create(:ranking, round: round1, player: player1) }
  let!(:ranking_1_2) { create(:ranking, round: round1, player: player2) }
  let!(:ranking_1_3) { create(:ranking, round: round1, player: player3) }
  let!(:ranking_1_4) { create(:ranking, round: round1, player: player4) }
  let!(:ranking_1_5) { create(:ranking, round: round1, player: player5) }
  let!(:ranking_1_6) { create(:ranking, round: round1, player: player6) }
  let!(:ranking_1_7) { create(:ranking, round: round1, player: player7) }
  let!(:ranking_1_8) { create(:ranking, round: round1, player: player8) }
  let!(:ranking_2_1) { create(:ranking, round: round2, player: player1) }
  let!(:ranking_2_2) { create(:ranking, round: round2, player: player2) }
  let!(:ranking_2_3) { create(:ranking, round: round2, player: player3) }
  let!(:ranking_2_4) { create(:ranking, round: round2, player: player4) }
  let!(:ranking_2_5) { create(:ranking, round: round2, player: player5) }
  let!(:ranking_2_6) { create(:ranking, round: round2, player: player6) }
  let!(:ranking_2_7) { create(:ranking, round: round2, player: player7) }
  let!(:ranking_2_8) { create(:ranking, round: round2, player: player8) }
  let!(:ranking_3_1) { create(:ranking, round: round3, player: player1) }
  let!(:ranking_3_2) { create(:ranking, round: round3, player: player2) }
  let!(:ranking_3_3) { create(:ranking, round: round3, player: player3) }
  let!(:ranking_3_4) { create(:ranking, round: round3, player: player4) }
  let!(:ranking_3_5) { create(:ranking, round: round3, player: player5) }
  let!(:ranking_3_6) { create(:ranking, round: round3, player: player6) }
  let!(:ranking_3_7) { create(:ranking, round: round3, player: player7) }
  let!(:ranking_3_8) { create(:ranking, round: round3, player: player8) }

  context 'With round 1 matches' do
    let!(:match_1_1_2) { create(:match, :finished, round: round1, player1: player1, player2: player2,
      players: [player1, player2], set1_player1_score: 6, set1_player2_score: 4, set2_player1_score: nil, set2_player2_score: nil,
      winner: player1, looser: player2) }
    let!(:match_1_3_4) { create(:match, :finished, round: round1, player1: player3, player2: player4,
      players: [player3, player4], set1_player1_score: 2, set1_player2_score: 6, set2_player1_score: nil, set2_player2_score: nil,
      winner: player4, looser: player3) }
    let!(:match_1_5_6) { create(:match, :finished, round: round1, player1: player5, player2: player6,
      players: [player5, player6], set1_player1_score: nil, set1_player2_score: nil, set2_player1_score: nil, set2_player2_score: nil,
      winner: player6, looser: player5, retired_player: player5) }
    let!(:match_1_7_8) { create(:match, :finished, round: round1, player1: player7, player2: player8,
      players: [player7, player8], set1_player1_score: 3, set1_player2_score: 5, set2_player1_score: nil, set2_player2_score: nil,
      winner: player8, looser: player7, retired_player: player7) }

    it 'Sets rankings correctly' do
      result = calculation

      expect(result.find { |r| r[:id] == ranking_1_1.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_1_2.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_1_3.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -4, relevant: true)
      expect(result.find { |r| r[:id] == ranking_1_4.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 4, relevant: true)
      expect(result.find { |r| r[:id] == ranking_1_5.id }).to include(points: 0, toss_points: 0, handicap: 0, sets_difference: 0, games_difference: 0, relevant: false)
      expect(result.find { |r| r[:id] == ranking_1_6.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 0, relevant: true)
      expect(result.find { |r| r[:id] == ranking_1_7.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: -2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_1_8.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 2, relevant: true)

      expect(result.find { |r| r[:id] == ranking_2_1.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_2_2.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_2_3.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -4, relevant: true)
      expect(result.find { |r| r[:id] == ranking_2_4.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 4, relevant: true)
      expect(result.find { |r| r[:id] == ranking_2_5.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: 0, relevant: false)
      expect(result.find { |r| r[:id] == ranking_2_6.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 0, relevant: true)
      expect(result.find { |r| r[:id] == ranking_2_7.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: -2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_2_8.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 2, relevant: true)

      expect(result.find { |r| r[:id] == ranking_3_1.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_3_2.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_3_3.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -4, relevant: true)
      expect(result.find { |r| r[:id] == ranking_3_4.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 4, relevant: true)
      expect(result.find { |r| r[:id] == ranking_3_5.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: 0, relevant: false)
      expect(result.find { |r| r[:id] == ranking_3_6.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 0, relevant: true)
      expect(result.find { |r| r[:id] == ranking_3_7.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: -2, relevant: true)
      expect(result.find { |r| r[:id] == ranking_3_8.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 2, relevant: true)
    end

    context 'With round 2 matches' do
      let!(:match_2_1_6) { create(:match, :finished, round: round2, player1: player1, player2: player6,
        players: [player1, player6], set1_player1_score: 6, set1_player2_score: 3, set2_player1_score: nil, set2_player2_score: nil,
        winner: player1, looser: player6) }
      let!(:match_2_2_5) { create(:match, :finished, round: round2, player1: player2, player2: player5,
        players: [player2, player5], set1_player1_score: 1, set1_player2_score: 6, set2_player1_score: nil, set2_player2_score: nil,
        winner: player5, looser: player2) }
      let!(:match_2_3_7) { create(:match, :finished, round: round2, player1: player3, player2: player7,
        players: [player3, player7], set1_player1_score: 7, set1_player2_score: 6, set2_player1_score: nil, set2_player2_score: nil,
        winner: player3, looser: player7) }
      let!(:match_2_4_8) { create(:match, :finished, round: round2, player1: player4, player2: player8,
        players: [player4, player8], set1_player1_score: 7, set1_player2_score: 5, set2_player1_score: nil, set2_player2_score: nil,
        winner: player4, looser: player8) }

      it 'Sets rankings correctly' do
        result = calculation

        expect(result.find { |r| r[:id] == ranking_1_1.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 2, relevant: true)
        expect(result.find { |r| r[:id] == ranking_1_2.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -2, relevant: true)
        expect(result.find { |r| r[:id] == ranking_1_3.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -4, relevant: true)
        expect(result.find { |r| r[:id] == ranking_1_4.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 4, relevant: true)
        expect(result.find { |r| r[:id] == ranking_1_5.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: 0, relevant: false)
        expect(result.find { |r| r[:id] == ranking_1_6.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 0, relevant: true)
        expect(result.find { |r| r[:id] == ranking_1_7.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: -2, relevant: true)
        expect(result.find { |r| r[:id] == ranking_1_8.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 2, relevant: true)

        expect(result.find { |r| r[:id] == ranking_2_1.id }).to include(points: 2, toss_points: 2, handicap: 1, sets_difference: 2, games_difference: 5, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_2.id }).to include(points: 0, toss_points: 0, handicap: 3, sets_difference: -2, games_difference: -7, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_3.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: 0, games_difference: -3, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_4.id }).to include(points: 2, toss_points: 2, handicap: 2, sets_difference: 2, games_difference: 6, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_5.id }).to include(points: 1, toss_points: 1, handicap: 1, sets_difference: -1, games_difference: 5, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_6.id }).to include(points: 1, toss_points: 1, handicap: 3, sets_difference: 1, games_difference: -3, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_7.id }).to include(points: 0, toss_points: 0, handicap: 2, sets_difference: -3, games_difference: -3, relevant: true)
        expect(result.find { |r| r[:id] == ranking_2_8.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 0, relevant: true)

        expect(result.find { |r| r[:id] == ranking_3_1.id }).to include(points: 2, toss_points: 2, handicap: 1, sets_difference: 2, games_difference: 5, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_2.id }).to include(points: 0, toss_points: 0, handicap: 3, sets_difference: -2, games_difference: -7, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_3.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: 0, games_difference: -3, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_4.id }).to include(points: 2, toss_points: 2, handicap: 2, sets_difference: 2, games_difference: 6, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_5.id }).to include(points: 1, toss_points: 1, handicap: 1, sets_difference: -1, games_difference: 5, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_6.id }).to include(points: 1, toss_points: 1, handicap: 3, sets_difference: 1, games_difference: -3, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_7.id }).to include(points: 0, toss_points: 0, handicap: 2, sets_difference: -3, games_difference: -3, relevant: true)
        expect(result.find { |r| r[:id] == ranking_3_8.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 0, relevant: true)
      end

      context 'With round 3 matches' do
        let!(:match_3_1_4) { create(:match, :finished, round: round3, player1: player1, player2: player4,
          players: [player1, player4], set1_player1_score: 6, set1_player2_score: 4, set2_player1_score: nil, set2_player2_score: nil,
          winner: player1, looser: player4) }
        let!(:match_3_2_7) { create(:match, :finished, round: round3, player1: player2, player2: player7,
          players: [player2, player7], set1_player1_score: 3, set1_player2_score: 6, set2_player1_score: nil, set2_player2_score: nil,
          winner: player7, looser: player2) }
        let!(:match_3_3_6) { create(:match, :finished, round: round3, player1: player3, player2: player6,
          players: [player3, player6], set1_player1_score: 5, set1_player2_score: 7, set2_player1_score: nil, set2_player2_score: nil,
          winner: player6, looser: player3) }
        let!(:match_3_5_8) { create(:match, :finished, round: round3, player1: player5, player2: player8,
          players: [player5, player8], set1_player1_score: 6, set1_player2_score: 0, set2_player1_score: nil, set2_player2_score: nil,
          winner: player5, looser: player8) }

        it 'Sets rankings correctly' do
          result = calculation

          expect(result.find { |r| r[:id] == ranking_1_1.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 2)
          expect(result.find { |r| r[:id] == ranking_1_2.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -2)
          expect(result.find { |r| r[:id] == ranking_1_3.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -1, games_difference: -4)
          expect(result.find { |r| r[:id] == ranking_1_4.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 1, games_difference: 4)
          expect(result.find { |r| r[:id] == ranking_1_5.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: 0)
          expect(result.find { |r| r[:id] == ranking_1_6.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 0)
          expect(result.find { |r| r[:id] == ranking_1_7.id }).to include(points: 0, toss_points: 0, handicap: 1, sets_difference: -2, games_difference: -2)
          expect(result.find { |r| r[:id] == ranking_1_8.id }).to include(points: 1, toss_points: 1, handicap: 0, sets_difference: 2, games_difference: 2)

          expect(result.find { |r| r[:id] == ranking_2_1.id }).to include(points: 2, toss_points: 2, handicap: 1, sets_difference: 2, games_difference: 5)
          expect(result.find { |r| r[:id] == ranking_2_2.id }).to include(points: 0, toss_points: 0, handicap: 3, sets_difference: -2, games_difference: -7)
          expect(result.find { |r| r[:id] == ranking_2_3.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: 0, games_difference: -3)
          expect(result.find { |r| r[:id] == ranking_2_4.id }).to include(points: 2, toss_points: 2, handicap: 2, sets_difference: 2, games_difference: 6)
          expect(result.find { |r| r[:id] == ranking_2_5.id }).to include(points: 1, toss_points: 1, handicap: 1, sets_difference: -1, games_difference: 5)
          expect(result.find { |r| r[:id] == ranking_2_6.id }).to include(points: 1, toss_points: 1, handicap: 3, sets_difference: 1, games_difference: -3)
          expect(result.find { |r| r[:id] == ranking_2_7.id }).to include(points: 0, toss_points: 0, handicap: 2, sets_difference: -3, games_difference: -3)
          expect(result.find { |r| r[:id] == ranking_2_8.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 0)

          expect(result.find { |r| r[:id] == ranking_3_1.id }).to include(points: 3, toss_points: 3, handicap: 4, sets_difference: 3, games_difference: 7)
          expect(result.find { |r| r[:id] == ranking_3_2.id }).to include(points: 0, toss_points: 0, handicap: 6, sets_difference: -3, games_difference: -10)
          expect(result.find { |r| r[:id] == ranking_3_3.id }).to include(points: 1, toss_points: 1, handicap: 5, sets_difference: -1, games_difference: -5)
          expect(result.find { |r| r[:id] == ranking_3_4.id }).to include(points: 2, toss_points: 2, handicap: 5, sets_difference: 1, games_difference: 4)
          expect(result.find { |r| r[:id] == ranking_3_5.id }).to include(points: 2, toss_points: 2, handicap: 3, sets_difference: 0, games_difference: 11)
          expect(result.find { |r| r[:id] == ranking_3_6.id }).to include(points: 2, toss_points: 2, handicap: 6, sets_difference: 2, games_difference: -1)
          expect(result.find { |r| r[:id] == ranking_3_7.id }).to include(points: 1, toss_points: 1, handicap: 2, sets_difference: -2, games_difference: 0)
          expect(result.find { |r| r[:id] == ranking_3_8.id }).to include(points: 1, toss_points: 1, handicap: 5, sets_difference: 0, games_difference: -6)
        end
      end
    end
  end
end
