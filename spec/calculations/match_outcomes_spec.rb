require 'rails_helper'

describe MatchOutcomes do
  subject(:calculation_result) do
    described_class.result_for(match: a_match)
  end

  let!(:playerA) { create(:player) }
  let!(:playerB) { create(:player) }

  context "Match won by player1 with result 2:0" do
    let!(:a_match) do
      create(:match, :finished, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: 6, set1_player2_score: 4,
             set2_player1_score: 6, set2_player2_score: 1,
             set3_player1_score: nil, set3_player2_score: nil,
             winner: playerA, looser: playerB)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 3,
                                           :winner_sets_difference => 2,
                                           :winner_games_difference => 7,
                                           :looser_points => 0
                                       })
    end
  end

  context "Match won by player2 with result 2:1" do
    let!(:a_match) do
      create(:match, :finished, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: 6, set1_player2_score: 2,
             set2_player1_score: 3, set2_player2_score: 6,
             set3_player1_score: 6, set3_player2_score: 7,
             winner: playerB, looser: playerA)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 2,
                                           :winner_sets_difference => 1,
                                           :winner_games_difference => 0,
                                           :looser_points => 1
                                       })

    end
  end

  context "Match retired by player1 during (or after) 1st set" do
    let!(:a_match) do
      create(:match, :finished, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: 1, set1_player2_score: 4,
             set2_player1_score: nil, set2_player2_score: nil,
             set3_player1_score: nil, set3_player2_score: nil,
             retired_player: playerA, looser: playerA, winner: playerB)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 3,
                                           :winner_sets_difference => 0,
                                           :winner_games_difference => 3,
                                           :looser_points => 0
                                       })
    end
  end

  context "Player2 won 1st set and retired during 2nd set" do
    let!(:a_match) do
      create(:match, :finished, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: 3, set1_player2_score: 6,
             set2_player1_score: 1, set2_player2_score: 3,
             set3_player1_score: nil, set3_player2_score: nil,
             retired_player: playerB, looser: playerB, winner: playerA)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 2,
                                           :winner_sets_difference => -1,
                                           :winner_games_difference => -5,
                                           :looser_points => 1
                                       })
    end
  end

  context "Match retired by player1 during 3rd set" do
    let!(:a_match) do
      create(:match, :finished, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: 6, set1_player2_score: 2,
             set2_player1_score: 3, set2_player2_score: 6,
             set3_player1_score: 3, set3_player2_score: 3,
             retired_player: playerA, looser: playerA, winner: playerB)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 2,
                                           :winner_sets_difference => 0,
                                           :winner_games_difference => -1,
                                           :looser_points => 1
                                       })
    end
  end

  context "Match retired by player2 - refused to start playing" do
    let!(:a_match) do
      create(:match, :finished, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: nil, set1_player2_score: nil,
             set2_player1_score: nil, set2_player2_score: nil,
             set3_player1_score: nil, set3_player2_score: nil,
             retired_player: playerB, looser: playerB, winner: playerA)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 3,
                                           :winner_sets_difference => 2,
                                           :winner_games_difference => 12,
                                           :looser_points => 0
                                       })
    end
  end

  context "Match retired by player1 as a dummy player" do
    let!(:dummy_player) { create(:player, :dummy) }
    let!(:a_match) do
      create(:match, :finished, player1: dummy_player, player2: playerB, players: [dummy_player, playerB],
             set1_player1_score: nil, set1_player2_score: nil,
             set2_player1_score: nil, set2_player2_score: nil,
             set3_player1_score: nil, set3_player2_score: nil,
             retired_player: dummy_player, looser: dummy_player, winner: playerB)
    end

    it "Returns correct outcomes" do
      expect(calculation_result).to eq({
                                           :winner_points => 3,
                                           :winner_sets_difference => 2,
                                           :winner_games_difference => 12,
                                           :looser_points => 0
                                       })
    end
  end

  context "Unfinished match" do
    let!(:a_match) do
      create(:match, player1: playerA, player2: playerB, players: [playerA, playerB],
             set1_player1_score: 6, set1_player2_score: 4,
             set2_player1_score: 6, set2_player2_score: 1,
             set3_player1_score: nil, set3_player2_score: nil,
             winner: playerA, looser: playerB)
    end

    it "Returns zero outcomes" do
      expect(calculation_result).to eq({
                                         :winner_points => 0,
                                         :winner_sets_difference => 0,
                                         :winner_games_difference => 0,
                                         :looser_points => 0
                                       })
    end
  end
end