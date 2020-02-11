require 'rails_helper'

describe EnrollPlayerToSeason do
  subject(:enroll_player_to_season) { described_class.call(player_id, season).result }

  let!(:season) { create(:season) }

  context 'With valid player_id' do
    let!(:player) { create(:player) }
    let(:player_id) { player.id }

    it 'Enrolls given player to given season' do
      enroll_player_to_season

      expect(player.seasons).to include(season)
    end

    it 'Returns persisted enrollment' do
      enrollment = enroll_player_to_season

      expect(enrollment).to be_an(Enrollment)
      expect(enrollment.persisted?).to be(true)
    end

    context 'When season has two existing rounds already' do
      let!(:round1) { create(:round, season: season, position: 1) }
      let!(:round2) { create(:round, season: season, position: 2) }

      before do
        round1.insert_at(1)
        round2.insert_at(2)
      end

      it 'Creates ranking for the player for last existing round of given season' do
        enroll_player_to_season

        expect(Ranking.find_by(player: player, round: round2)).not_to be_nil
      end
    end

    context 'With existing previously canceled enrollment' do
      let!(:canceled_enrollment) { create(:enrollment, :canceled, player: player, season: season) }

      it 'Reverts cancelation' do
        enrollment = enroll_player_to_season

        expect(enrollment.canceled?).to be(false)
      end
    end

    context 'With 6 existing rounds and player having ranking only in the 2nd and 3rd round' do
      let!(:round1) { create(:round, season: season) }
      let!(:round2) { create(:round, season: season) }
      let!(:round3) { create(:round, season: season) }
      let!(:round4) { create(:round, season: season) }
      let!(:round5) { create(:round, season: season) }
      let!(:round6) { create(:round, season: season) }

      before do
        round1.insert_at(1)
        round2.insert_at(2)
        round3.insert_at(3)
        round4.insert_at(4)
        round5.insert_at(5)
        round6.insert_at(6)

        player.rankings.create!(round: round2, points: 1, handicap: 1, sets_difference: 1, games_difference: 1, relevant: true)
        player.rankings.create!(round: round3, points: 4, handicap: 4, sets_difference: 4, games_difference: 4, relevant: true)
      end

      it 'Creates copies of the latest ranking of the player for rounds 3-6' do
        enroll_player_to_season

        expect(round1.rankings.find_by(player: player)).to be_nil
        expect(round2.rankings.find_by(player: player)).to have_attributes(points: 1, handicap: 1, sets_difference: 1, games_difference: 1, relevant: true)
        expect(round3.rankings.find_by(player: player)).to have_attributes(points: 4, handicap: 4, sets_difference: 4, games_difference: 4, relevant: true)
        expect(round4.rankings.find_by(player: player)).to have_attributes(points: 4, handicap: 4, sets_difference: 4, games_difference: 4, relevant: true)
        expect(round5.rankings.find_by(player: player)).to have_attributes(points: 4, handicap: 4, sets_difference: 4, games_difference: 4, relevant: true)
        expect(round6.rankings.find_by(player: player)).to have_attributes(points: 4, handicap: 4, sets_difference: 4, games_difference: 4, relevant: true)
      end
    end
  end

  context 'With invalid player_id' do
    let!(:player) { create(:player) }
    let(:player_id) { nil }

    it 'Returns unpersisted enrollment' do
      enrollment = enroll_player_to_season

      expect(enrollment.persisted?).to be(false)
    end
  end
end
