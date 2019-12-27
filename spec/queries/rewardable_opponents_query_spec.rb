require 'rails_helper'

describe RewardableOpponentsQuery do
  subject(:query) { described_class.call(player: player, round: round) }

  let!(:season) { create(:season, name: 'This season') }
  let!(:previous_season) { create(:season, name: 'Previous season') }

  let!(:season_round1) { create(:round, season: season, position: 1) }
  let!(:season_round2) { create(:round, season: season, position: 2) }
  let!(:season_round3) { create(:round, season: season, position: 3) }
  let!(:season_round4) { create(:round, season: season, position: 4) }
  let!(:season_round5) { create(:round, season: season, position: 5) }
  let!(:season_round6) { create(:round, season: season, position: 6) }
  let!(:season_round7) { create(:round, season: season, position: 7) }
  let!(:previous_season_round1) { create(:round, season: previous_season, position: 1) }
  let!(:previous_season_round2) { create(:round, season: previous_season, position: 2) }

  let!(:player) { create(:player) }
  let!(:retired_opponent1) { create(:player) }
  let!(:retired_opponent2) { create(:player) }

  let!(:season_round1_match) { create(:match, :finished, round: season_round1, player2: player) }
  let!(:season_round2_match) { create(:match, :finished, round: season_round2, player1: player, player2: retired_opponent1, retired_player: retired_opponent1, set1_player1_score: nil, set1_player2_score: nil) }
  let!(:season_round3_match) { create(:match, :finished, round: season_round3, player1: retired_opponent2, player2: player, retired_player: retired_opponent2, set1_player1_score: 1, set1_player2_score: 3) }
  let!(:season_round4_match) { create(:match, :finished, round: season_round4, player1: player, retired_player: player, set1_player1_score: nil, set1_player2_score: nil) }
  let!(:season_round5_match) { create(:match, :finished, round: season_round5, player2: player, retired_player: player, set1_player1_score: 1, set1_player2_score: 3) }
  let!(:season_round6_match) { create(:match, round: season_round6, player2: player) }
  let!(:season_round7_match) { create(:match, :finished, round: season_round7, player2: player) }
  let!(:previous_season_round1_match) { create(:match, :finished, round: previous_season_round1, player1: player) }
  let!(:previous_season_round2_match) { create(:match, :finished, round: previous_season_round2, player2: player) }

  before do
    season_round1.insert_at(1)
    season_round2.insert_at(2)
    season_round3.insert_at(3)
    season_round4.insert_at(4)
    season_round5.insert_at(5)
    season_round6.insert_at(6)
    season_round7.insert_at(7)
    previous_season_round1.insert_at(1)
    previous_season_round2.insert_at(2)
  end

  context 'With season_round4' do
    let(:round) { season_round4 }

    it 'Returns players who were real opponents of given player from finished matches of previous rounds, those who played at least one game' do
      opponents = query

      expect(opponents.count).to eq 2
      expect(opponents).to match_array [
                                           season_round1_match.player1,
                                           season_round3_match.player1
                                       ]
    end
  end

  context 'With season_round7' do
    let(:round) { season_round7 }

    it 'Returns players who were real opponents of given player from finished matches of previous rounds, those who played at least one game' do
      opponents = query

      expect(opponents.count).to eq 4
      expect(opponents).to match_array [
                                           season_round1_match.player1,
                                           season_round3_match.player1,
                                           season_round4_match.player2,
                                           season_round5_match.player1
                                       ]
    end
  end

  context 'With previous_season_round2' do
    let(:round) { previous_season_round2 }

    it 'Returns players who were real opponents of given player from finished matches of previous rounds, those who played at least one game' do
      opponents = query

      expect(opponents.count).to eq 1
      expect(opponents).to match_array [previous_season_round1_match.player2]
    end
  end
end
