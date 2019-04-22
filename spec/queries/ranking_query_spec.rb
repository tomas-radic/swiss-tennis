require 'rails_helper'

describe RankingQuery do
  subject(:ranking_query) { RankingQuery.call(round: round) }

=begin    TESTING SCHEMA
      p h d c  (p: points, h: handicap, d: games_difference, c: created_at)
  Round 1
  p1: 4 3 7 3
  p2: 4 3 7 2
  p3: 4 3 7 1   => 3, 2, 1

  Round 2
  p1: 4 3 7 3
  p2: 4 3 8 2
  p3: 4 3 7 1   => 2, 3, 1

  Round 3
  p1: 4 4 7 3
  p2: 4 3 8 2
  p3: 4 3 7 1   => 1, 2, 3

  Round 4
  p1: 4 4 7 3
  p2: 5 3 8 2
  p3: 4 3 7 1   => 2, 1, 3
=end

  let!(:round1) { create(:round) }
  let!(:round2) { create(:round) }
  let!(:round3) { create(:round) }
  let!(:round4) { create(:round) }
  let!(:player1) { create(:player, created_at: 1.minute.ago) }
  let!(:player2) { create(:player, created_at: 3.minutes.ago) }
  let!(:player3) { create(:player, created_at: 5.minutes.ago) }
  let!(:ranking11) { create(:ranking, round: round1, player: player1, points: 4, handicap: 3, games_difference: 7) }
  let!(:ranking12) { create(:ranking, round: round1, player: player2, points: 4, handicap: 3, games_difference: 7) }
  let!(:ranking13) { create(:ranking, round: round1, player: player3, points: 4, handicap: 3, games_difference: 7) }
  let!(:ranking21) { create(:ranking, round: round2, player: player1, points: 4, handicap: 3, games_difference: 7) }
  let!(:ranking22) { create(:ranking, round: round2, player: player2, points: 4, handicap: 3, games_difference: 8) }
  let!(:ranking23) { create(:ranking, round: round2, player: player3, points: 4, handicap: 3, games_difference: 7) }
  let!(:ranking31) { create(:ranking, round: round3, player: player1, points: 4, handicap: 4, games_difference: 7) }
  let!(:ranking32) { create(:ranking, round: round3, player: player2, points: 4, handicap: 3, games_difference: 8) }
  let!(:ranking33) { create(:ranking, round: round3, player: player3, points: 4, handicap: 3, games_difference: 7) }
  let!(:ranking41) { create(:ranking, round: round4, player: player1, points: 4, handicap: 4, games_difference: 7) }
  let!(:ranking42) { create(:ranking, round: round4, player: player2, points: 5, handicap: 3, games_difference: 8) }
  let!(:ranking43) { create(:ranking, round: round4, player: player3, points: 4, handicap: 3, games_difference: 7) }


  describe 'Querying current round' do
    let(:round) { round4 }

    it 'Orders results correctly' do
      result = ranking_query

      expect(result[0].player).to eq player2
      expect(result[1].player).to eq player1
      expect(result[2].player).to eq player3
    end
  end

  describe 'Querying round 3' do
    let(:round) { round3 }

    it 'Orders results correctly' do
      result = ranking_query

      expect(result[0].player).to eq player1
      expect(result[1].player).to eq player2
      expect(result[2].player).to eq player3
    end
  end

  describe 'Querying round 2' do
    let(:round) { round2 }

    it 'Orders results correctly' do
      result = ranking_query

      expect(result[0].player).to eq player2
      expect(result[1].player).to eq player3
      expect(result[2].player).to eq player1
    end
  end

  describe 'Querying round 1' do
    let(:round) { round1 }

    it 'Orders results correctly' do
      result = ranking_query

      expect(result[0].player).to eq player3
      expect(result[1].player).to eq player2
      expect(result[2].player).to eq player1
    end
  end
end
