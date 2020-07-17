require "rails_helper"

describe DelayedMatchesQuery do
  subject(:query) { described_class.call(round: round) }

  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:round3) { create(:round, season: season) }
  let!(:canceled_enrollment) { create(:enrollment, :canceled, season: season) }
  let!(:enrollment1) { create(:enrollment, season: season) }
  let!(:enrollment2) { create(:enrollment, season: season) }
  let!(:enrollment3) { create(:enrollment, season: season) }
  let!(:enrollment4) { create(:enrollment, season: season) }
  let!(:enrollment5) { create(:enrollment, season: season) }
  let!(:enrollment6) { create(:enrollment, season: season) }


  let!(:match_r1_finished) {  create(:match, :finished, round: round1, player1: enrollment1.player, player2: enrollment2.player) }
  let!(:match_r1_unfinished) { create(:match, :published, round: round1, player1: enrollment3.player, player2: enrollment4.player) }
  let!(:match_r2_unfinished) { create(:match, :published, round: round2, player1: enrollment1.player, player2: enrollment3.player) }
  let!(:match_r2_unfinished_unpublished) { create(:match, :draft, round: round2, player1: enrollment2.player, player2: enrollment4.player) }
  let!(:match_r2_unfinished_dummy) { create(:match, :published, player1: enrollment5.player, player2: create(:player, :dummy), round: round2) }
  let!(:match_r2_unfinished_canceled) { create(:match, :published, player1: canceled_enrollment.player, player2: enrollment6.player, round: round2) }
  let!(:match_r3_unfinished) { create(:match, :published, round: round3, player1: enrollment1.player, player2: enrollment5.player) }

  let!(:previous_season) { create(:season) }
  let!(:enrollment1_ps) { create(:enrollment, season: previous_season) }
  let!(:enrollment2_ps) { create(:enrollment, season: previous_season) }
  let!(:round1_ps) { create(:round, season: previous_season) }
  let!(:match_r1_ps_unfinished) { create(:match, :published, round: round1_ps, player1: enrollment1_ps.player, player2: enrollment2_ps.player) }

  context "With round 3" do
    let(:round) { round3 }

    it "Returns delayed matches from round3 point of view" do
      result = query

      expect(result.count).to eq(2)
      expect(result).to include(match_r1_unfinished, match_r2_unfinished)
    end
  end

  context "With round 2" do
    let(:round) { round2 }

    it "Returns delayed matches from round2 point of view" do
      result = query

      expect(result.count).to eq(1)
      expect(result).to include(match_r1_unfinished)
    end
  end

  context "With round 1" do
    let(:round) { round1 }

    it "Returns delayed matches from round1 point of view" do
      expect(query).to be_empty
    end
  end
end