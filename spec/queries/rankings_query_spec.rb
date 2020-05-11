require 'rails_helper'

describe RankingsQuery do
  subject(:rankings_query) { RankingsQuery.call(round: round) }

=begin    TESTING SCHEMA
      r p h s g c  (r: relevant, p: points, h: handicap, s: sets_difference, g: games_difference, c: player.enrollment.created_at)
  Round 1
  p1: 1 4 3 3 7 3
  p2: 1 4 3 3 7 2
  p3: 1 4 3 3 7 1   => 3, 2, 1

  Round 2
  p1: 1 4 3 3 7 3
  p2: 1 4 3 3 8 2
  p3: 1 4 3 3 7 1   => 2, 3, 1

  Round 3
  p1: 1 4 4 3 7 3
  p2: 1 4 3 3 8 2
  p3: 1 4 3 3 7 1   => 1, 2, 3

  Round 4
  p1: 1 4 4 3 7 3
  p2: 1 5 3 3 8 2
  p3: 1 4 3 3 7 1   => 2, 1, 3

  Round 5
  p1: 1 2 3 5 7 3
  p2: 1 2 3 3 8 2
  p3: 0 7 8 4 9 1   => 1, 2, 3
=end

  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:round3) { create(:round, season: season) }
  let!(:round4) { create(:round, season: season) }
  let!(:round5) { create(:round, season: season) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:player3) { create(:player) }
  let!(:enrollment1) { create(:enrollment, player: player1, season: season, created_at: 1.minute.ago) }
  let!(:enrollment2) { create(:enrollment, player: player2, season: season, created_at: 3.minute.ago) }
  let!(:enrollment3) { create(:enrollment, player: player3, season: season, created_at: 5.minute.ago) }
  let!(:ranking11) { create(:ranking, :relevant, round: round1, player: player1, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking12) { create(:ranking, :relevant, round: round1, player: player2, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking13) { create(:ranking, :relevant, round: round1, player: player3, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking21) { create(:ranking, :relevant, round: round2, player: player1, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking22) { create(:ranking, :relevant, round: round2, player: player2, points: 4, handicap: 3, sets_difference: 3, games_difference: 8) }
  let!(:ranking23) { create(:ranking, :relevant, round: round2, player: player3, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking31) { create(:ranking, :relevant, round: round3, player: player1, points: 4, handicap: 4, sets_difference: 3, games_difference: 7) }
  let!(:ranking32) { create(:ranking, :relevant, round: round3, player: player2, points: 4, handicap: 3, sets_difference: 3, games_difference: 8) }
  let!(:ranking33) { create(:ranking, :relevant, round: round3, player: player3, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking41) { create(:ranking, :relevant, round: round4, player: player1, points: 4, handicap: 4, sets_difference: 3, games_difference: 7) }
  let!(:ranking42) { create(:ranking, :relevant, round: round4, player: player2, points: 5, handicap: 3, sets_difference: 3, games_difference: 8) }
  let!(:ranking43) { create(:ranking, :relevant, round: round4, player: player3, points: 4, handicap: 3, sets_difference: 3, games_difference: 7) }
  let!(:ranking51) { create(:ranking, :relevant, round: round5, player: player1, points: 2, handicap: 3, sets_difference: 5, games_difference: 7) }
  let!(:ranking52) { create(:ranking, :relevant, round: round5, player: player2, points: 2, handicap: 3, sets_difference: 3, games_difference: 8) }
  let!(:ranking53) { create(:ranking, round: round5, player: player3, points: 7, handicap: 8, sets_difference: 4, games_difference: 9) }


  describe 'Querying round 5' do
    let(:round) { round5 }

    it 'Orders results correctly' do
      result = rankings_query

      expect(result[0].player).to eq player1
      expect(result[1].player).to eq player2
      expect(result[2].player).to eq player3
    end
  end

  describe 'Querying round 4' do
    let(:round) { round4 }

    it 'Orders results correctly' do
      result = rankings_query

      expect(result[0].player).to eq player2
      expect(result[1].player).to eq player1
      expect(result[2].player).to eq player3
    end
  end

  describe 'Querying round 3' do
    let(:round) { round3 }

    it 'Orders results correctly' do
      result = rankings_query

      expect(result[0].player).to eq player1
      expect(result[1].player).to eq player2
      expect(result[2].player).to eq player3
    end
  end

  describe 'Querying round 2' do
    let(:round) { round2 }

    it 'Orders results correctly' do
      result = rankings_query

      expect(result[0].player).to eq player2
      expect(result[1].player).to eq player3
      expect(result[2].player).to eq player1
    end
  end

  describe 'Querying round 1' do
    let(:round) { round1 }

    it 'Orders results correctly' do
      result = rankings_query

      expect(result[0].player).to eq player3
      expect(result[1].player).to eq player2
      expect(result[2].player).to eq player1
    end
  end

  describe 'Querying nil round' do
    let(:round) { nil }

    it 'Returns empty resultset' do
      expect(rankings_query).to be_empty
    end
  end
end
