require "rails_helper"

describe DestroyMatch, type: :model do
  subject { described_class.call(a_match) }

  # Current season ################################################
  let!(:season) { create(:season) }
  let!(:playerA) { create(:player, first_name: "Player", last_name: "A", seasons: [season, season_p]) }
  let!(:playerB) { create(:player, first_name: "Player", last_name: "B", seasons: [season, season_p]) }

  let!(:round1) { create(:round, season: season) }
  let!(:ranking1A) { create(:ranking, round: round1, player: playerA,
                            points: 11, sets_difference: 12, games_difference: 13) }
  let!(:ranking1B) { create(:ranking, round: round1, player: playerB,
                            points: 14, sets_difference: 15, games_difference: 16) }

  let!(:round2) { create(:round, season: season) }
  let!(:ranking2A) { create(:ranking, round: round2, player: playerA,
                            points: 21, sets_difference: 22, games_difference: 23) }
  let!(:ranking2B) { create(:ranking, round: round2, player: playerB,
                            points: 24, sets_difference: 25, games_difference: 26) }

  let!(:round3) { create(:round, season: season) }
  let!(:ranking3A) { create(:ranking, round: round3, player: playerA,
                            points: 31, sets_difference: 32, games_difference: 33) }
  let!(:ranking3B) { create(:ranking, round: round3, player: playerB,
                            points: 34, sets_difference: 35, games_difference: 36) }


  # Previous season ################################################
  let!(:season_p) { create(:season) }

  let!(:round_p1) { create(:round, season: season_p) }
  let!(:ranking_p1A) { create(:ranking, round: round_p1, player: playerA,
                            points: 11, sets_difference: 12, games_difference: 13) }
  let!(:ranking_p1B) { create(:ranking, round: round_p1, player: playerB,
                            points: 14, sets_difference: 15, games_difference: 16) }

  let!(:round_p2) { create(:round, season: season_p) }
  let!(:ranking_p2A) { create(:ranking, round: round_p2, player: playerA,
                            points: 21, sets_difference: 22, games_difference: 23) }
  let!(:ranking_p2B) { create(:ranking, round: round_p2, player: playerB,
                            points: 24, sets_difference: 25, games_difference: 26) }

  let!(:round_p3) { create(:round, season: season_p) }
  let!(:ranking_p3A) { create(:ranking, round: round_p3, player: playerA,
                            points: 31, sets_difference: 32, games_difference: 33) }
  let!(:ranking_p3B) { create(:ranking, round: round_p3, player: playerB,
                            points: 34, sets_difference: 35, games_difference: 36) }


  before do
    round1.insert_at 1
    round2.insert_at 2
    round3.insert_at 3
    round_p1.insert_at 1
    round_p2.insert_at 2
    round_p3.insert_at 3
  end


  context "With unfinished match" do
    let(:a_match) { create(:match, round: round2, player1: playerA, player2: playerB,
                           players: [playerA, playerB]) }

    it "Destroys the match and does NOT change any rankings" do
      id = a_match.id
      subject

      expect(Match.find_by(id: id)).to be_nil
      expect(ranking1A.reload).to have_attributes(points: 11, sets_difference: 12, games_difference: 13)
      expect(ranking1B.reload).to have_attributes(points: 14, sets_difference: 15, games_difference: 16)
      expect(ranking2A.reload).to have_attributes(points: 21, sets_difference: 22, games_difference: 23)
      expect(ranking2B.reload).to have_attributes(points: 24, sets_difference: 25, games_difference: 26)
      expect(ranking3A.reload).to have_attributes(points: 31, sets_difference: 32, games_difference: 33)
      expect(ranking3B.reload).to have_attributes(points: 34, sets_difference: 35, games_difference: 36)
      expect(ranking_p1A.reload).to have_attributes(points: 11, sets_difference: 12, games_difference: 13)
      expect(ranking_p1B.reload).to have_attributes(points: 14, sets_difference: 15, games_difference: 16)
      expect(ranking_p2A.reload).to have_attributes(points: 21, sets_difference: 22, games_difference: 23)
      expect(ranking_p2B.reload).to have_attributes(points: 24, sets_difference: 25, games_difference: 26)
      expect(ranking_p3A.reload).to have_attributes(points: 31, sets_difference: 32, games_difference: 33)
      expect(ranking_p3B.reload).to have_attributes(points: 34, sets_difference: 35, games_difference: 36)
    end
  end


  context "With finished match" do
    let(:a_match) { create(:match, :finished, round: round2,
                           player1: playerA, player2: playerB, players: [playerA, playerB],
                           winner: playerA, looser: playerB,
                           set1_player1_score: 6, set1_player2_score: 3,
                           set2_player1_score: 4, set2_player2_score: 6,
                           set3_player1_score: 6, set3_player2_score: 3) }

    it "Destroys the match and updates the rankings" do
      id = a_match.id
      subject

      expect(Match.find_by(id: id)).to be_nil
      expect(ranking1A.reload).to have_attributes(points: 11, sets_difference: 12, games_difference: 13)
      expect(ranking1B.reload).to have_attributes(points: 14, sets_difference: 15, games_difference: 16)
      expect(ranking2A.reload).to have_attributes(points: 19, sets_difference: 21, games_difference: 19)
      expect(ranking2B.reload).to have_attributes(points: 23, sets_difference: 26, games_difference: 30)
      expect(ranking3A.reload).to have_attributes(points: 29, sets_difference: 31, games_difference: 29)
      expect(ranking3B.reload).to have_attributes(points: 33, sets_difference: 36, games_difference: 40)
      expect(ranking_p1A.reload).to have_attributes(points: 11, sets_difference: 12, games_difference: 13)
      expect(ranking_p1B.reload).to have_attributes(points: 14, sets_difference: 15, games_difference: 16)
      expect(ranking_p2A.reload).to have_attributes(points: 21, sets_difference: 22, games_difference: 23)
      expect(ranking_p2B.reload).to have_attributes(points: 24, sets_difference: 25, games_difference: 26)
      expect(ranking_p3A.reload).to have_attributes(points: 31, sets_difference: 32, games_difference: 33)
      expect(ranking_p3B.reload).to have_attributes(points: 34, sets_difference: 35, games_difference: 36)
    end
  end


  context "With retired match" do
    let(:a_match) { create(:match, :finished, round: round2,
                           player1: playerA, player2: playerB, players: [playerA, playerB],
                           retired_player: playerA, looser: playerA, winner: playerB,
                           set1_player1_score: nil, set1_player2_score: nil,
                           set2_player1_score: nil, set2_player2_score: nil,
                           set3_player1_score: nil, set3_player2_score: nil) }

    it "Destroys the match and updates the rankings" do
      id = a_match.id
      subject

      expect(Match.find_by(id: id)).to be_nil
      expect(ranking1A.reload).to have_attributes(points: 11, sets_difference: 12, games_difference: 13)
      expect(ranking1B.reload).to have_attributes(points: 14, sets_difference: 15, games_difference: 16)
      expect(ranking2A.reload).to have_attributes(points: 21, sets_difference: 24, games_difference: 35)
      expect(ranking2B.reload).to have_attributes(points: 21, sets_difference: 23, games_difference: 14)
      expect(ranking3A.reload).to have_attributes(points: 31, sets_difference: 34, games_difference: 45)
      expect(ranking3B.reload).to have_attributes(points: 31, sets_difference: 33, games_difference: 24)
      expect(ranking_p1A.reload).to have_attributes(points: 11, sets_difference: 12, games_difference: 13)
      expect(ranking_p1B.reload).to have_attributes(points: 14, sets_difference: 15, games_difference: 16)
      expect(ranking_p2A.reload).to have_attributes(points: 21, sets_difference: 22, games_difference: 23)
      expect(ranking_p2B.reload).to have_attributes(points: 24, sets_difference: 25, games_difference: 26)
      expect(ranking_p3A.reload).to have_attributes(points: 31, sets_difference: 32, games_difference: 33)
      expect(ranking_p3B.reload).to have_attributes(points: 34, sets_difference: 35, games_difference: 36)
    end
  end
end
