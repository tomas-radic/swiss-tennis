require 'rails_helper'

describe Handicap do

  subject { described_class.result_for(ranking: ranking,
                                       finished_season_matches: finished_season_matches,
                                       round_rankings: round_rankings,
                                       enrollments: season.enrollments,
                                       substitute_points: substitute_points(ranking.round)) }

  let!(:season) { create(:season) }

  # Player and player's rankings
  let!(:player) { create(:player, seasons: [season]) }
  let!(:ranking_r1) { create(:ranking, player: player, round: round1, points: 11) }
  let!(:ranking_r2) { create(:ranking, player: player, round: round2, points: 21) }
  let!(:ranking_r3) { create(:ranking, player: player, round: round3, points: 31) }
  let!(:ranking_r4) { create(:ranking, player: player, round: round4, points: 41) }
  let!(:ranking_r5) { create(:ranking, player: player, round: round5, points: 51) }
  let!(:ranking_r6) { create(:ranking, player: player, round: round6, points: 61) }
  let!(:ranking_r7) { create(:ranking, player: player, round: round7, points: 71) }

  # Player's opponents in season
  let!(:opponent1) { create(:player, seasons: [season]) }
  let!(:opponent2) { create(:player, seasons: [season]) }
  let!(:opponent3) { create(:player, seasons: [season]) }
  let!(:opponent4) { create(:player, seasons: [season]) }
  let!(:opponent5) { create(:player, seasons: [season]) }
  let!(:opponent6) { create(:player, seasons: [season]) }
  let!(:opponent7) { create(:player, seasons: [season]) }

  # Rounds and rankings of player's opponents
  let!(:round1) { create(:round, season: season, period_begins: Time.now - 156.hours, period_ends: Time.now - 132.hours, rankings: [create(:ranking, player: opponent1, points: 12), create(:ranking, player: opponent2, points: 13), create(:ranking, player: opponent3, points: 14), create(:ranking, player: opponent4, points: 15), create(:ranking, player: opponent5, points: 16), create(:ranking, player: opponent6, points: 17), create(:ranking, player: opponent7, points: 18)]) }
  let!(:round2) { create(:round, season: season, period_begins: Time.now - 132.hours, period_ends: Time.now - 108.hours, rankings: [create(:ranking, player: opponent1, points: 22), create(:ranking, player: opponent2, points: 23), create(:ranking, player: opponent3, points: 24), create(:ranking, player: opponent4, points: 25), create(:ranking, player: opponent5, points: 26), create(:ranking, player: opponent6, points: 27), create(:ranking, player: opponent7, points: 28)]) }
  let!(:round3) { create(:round, season: season, period_begins: Time.now - 108.hours, period_ends: Time.now - 84.hours, rankings: [create(:ranking, player: opponent1, points: 32), create(:ranking, player: opponent2, points: 33), create(:ranking, player: opponent3, points: 34), create(:ranking, player: opponent4, points: 35), create(:ranking, player: opponent5, points: 36), create(:ranking, player: opponent6, points: 37), create(:ranking, player: opponent7, points: 38)]) }
  let!(:round4) { create(:round, season: season, period_begins: Time.now - 84.hours, period_ends: Time.now - 60.hours, rankings: [create(:ranking, player: opponent1, points: 42), create(:ranking, player: opponent2, points: 43), create(:ranking, player: opponent3, points: 44), create(:ranking, player: opponent4, points: 45), create(:ranking, player: opponent5, points: 46), create(:ranking, player: opponent6, points: 47), create(:ranking, player: opponent7, points: 48)]) }
  let!(:round5) { create(:round, season: season, period_begins: Time.now - 60.hours, period_ends: Time.now - 36.hours, rankings: [create(:ranking, player: opponent1, points: 52), create(:ranking, player: opponent2, points: 53), create(:ranking, player: opponent3, points: 54), create(:ranking, player: opponent4, points: 55), create(:ranking, player: opponent5, points: 56), create(:ranking, player: opponent6, points: 57), create(:ranking, player: opponent7, points: 58)]) }
  let!(:round6) { create(:round, season: season, period_begins: Time.now - 36.hours, period_ends: Time.now - 12.hours, rankings: [create(:ranking, player: opponent1, points: 62), create(:ranking, player: opponent2, points: 63), create(:ranking, player: opponent3, points: 64), create(:ranking, player: opponent4, points: 65), create(:ranking, player: opponent5, points: 66), create(:ranking, player: opponent6, points: 67), create(:ranking, player: opponent7, points: 68)]) }
  let!(:round7) { create(:round, season: season, period_begins: Time.now - 12.hours, period_ends: Time.now + 12.hours, rankings: [create(:ranking, player: opponent1, points: 72), create(:ranking, player: opponent2, points: 73), create(:ranking, player: opponent3, points: 74), create(:ranking, player: opponent4, points: 75), create(:ranking, player: opponent5, points: 76), create(:ranking, player: opponent6, points: 77), create(:ranking, player: opponent7, points: 78)]) }

  # Matches in season
  let!(:match1) { create(:match, :finished, round: round1, player1: player, player2: opponent1, players: [player, opponent1],
                         winner: opponent1, looser: player, retired_player: nil,
                         set1_player1_score: 1, set1_player2_score: 6) }
  let!(:match2) { create(:match, :finished, round: round2, player1: opponent2, player2: player, players: [opponent2, player],
                         winner: opponent2, looser: player, retired_player: player,
                         set1_player1_score: nil, set1_player2_score: nil) }
  let!(:match3) { create(:match, :finished, round: round3, player1: player, player2: opponent3, players: [player, opponent3],
                         winner: player, looser: opponent3, retired_player: opponent3,
                         set1_player1_score: nil, set1_player2_score: nil) }
  let!(:match4) { create(:match, :finished, round: round4, player1: player, player2: opponent4, players: [player, opponent4],
                         winner: opponent4, looser: player, retired_player: player,
                         set1_player1_score: 4, set1_player2_score: 0) }
  let!(:match5) { create(:match, :finished, round: round5, player1: opponent5, player2: player, players: [opponent5, player],
                         winner: player, looser: opponent5, retired_player: opponent5,
                         set1_player1_score: 2, set1_player2_score: 5) }
  let!(:match6) { create(:match, round: round6, player1: opponent6, player2: player, players: [opponent6, player],
                         winner: nil, looser: nil, retired_player: nil,
                         set1_player1_score: nil, set1_player2_score: nil) }
  let!(:match7) { create(:match, :finished, round: round7, player1: player, player2: opponent7, players: [player, opponent7],
                         winner: player, looser: opponent7, retired_player: nil,
                         set1_player1_score: 6, set1_player2_score: 3) }

  let(:finished_season_matches) do
    ranking.round.season.matches.finished.joins(:round)
           .where("rounds.position <= ?", ranking.round.position)
           .includes(:round).map do |match|
      {
        id: match.id,
        round: match.round.position,
        player1_id: match.player1_id,
        player2_id: match.player2_id,
        winner_id: match.winner_id,
        set1_player1_score: match.set1_player1_score,
        set1_player2_score: match.set1_player2_score
      }
    end
  end

  let(:round_rankings) do
    ranking.round.rankings.includes(:round).map do |ranking|
      {
        player_id: ranking.player_id,
        round: ranking.round,
        points: ranking.points
      }
    end
  end


  def substitute_points(round)
    round.reload.rankings.pluck(:points).inject(0) { |sum, p| sum += p } / ranking.round.rankings.count
  end


  context "For round1" do
    let(:ranking) { ranking_r1 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(12)
    end
  end

  context "For round2" do
    let(:ranking) { ranking_r2 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(22 + 0) # player has not played match in round2, so 0 points to handicap
    end
  end

  context "For round3" do
    let(:ranking) { ranking_r3 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(32 + 0 + 34)
    end
  end

  context "For round4" do
    let(:ranking) { ranking_r4 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(42 + 0 + 44 + 45)
    end
  end

  context "For round5" do
    let(:ranking) { ranking_r5 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(52 + 0 + 54 + 55 + 56)
    end
  end

  context "For round6" do
    let(:ranking) { ranking_r6 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(62 + 0 + 64 + 65 + 66 + 0) # player's match in round6 is not finished
    end
  end

  context "For round7" do
    let(:ranking) { ranking_r7 }

    it "Returns calculated handicap of the ranking" do
      expect(subject).to eq(72 + 0 + 74 + 75 + 76 + 0 + 78)
    end
  end


  context "Opponent3 abandoned competition in round 5" do
    before do
      season.enrollments.find_by(player: opponent3).update!(canceled_at: 48.hours.ago)

      round5.rankings.find_by(player: opponent3).update!(points: 44)
      round6.rankings.find_by(player: opponent3).update!(points: 44)
      round7.rankings.find_by(player: opponent3).update!(points: 44)

      ranking_r6.update!(points: 100)
      ranking_r7.update!(points: 150)
    end


    context "For round1" do
      let(:ranking) { ranking_r1 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(12)
      end
    end

    context "For round2" do
      let(:ranking) { ranking_r2 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(22 + 0) # player has not played match in round2, so 0 points to handicap
      end
    end

    context "For round3" do
      let(:ranking) { ranking_r3 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(32 + 0 + 34)
      end
    end

    context "For round4" do
      let(:ranking) { ranking_r4 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(42 + 0 + 44 + 45)
      end
    end

    context "For round5" do
      let(:ranking) { ranking_r5 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(52 + 0 + 44 + 55 + 56) # opponent3 canceled enrollment in this round, still counted real points
      end
    end

    context "For round6" do
      let(:ranking) { ranking_r6 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(62 + 0 + substitute_points(ranking.round) + 65 + 66 + 0)  # 1) opponent3 has inactive enrollment, counted substitute_points instead
                                                                         # 2) player's match in round6 is not finished
      end
    end

    context "For round7" do
      let(:ranking) { ranking_r7 }

      it "Returns calculated handicap of the ranking" do
        expect(subject).to eq(72 + 0 + substitute_points(ranking.round) + 75 + 76 + 0 + 78)   # opponent3 has inactive enrollment, counted substitute_points instead
      end
    end
  end
end
