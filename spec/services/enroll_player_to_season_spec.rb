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
  end

  context 'With invalid player_id' do
    let!(:player) { create(:player) }
    let(:player_id) { nil }

    it 'Raises error' do
      expect { enroll_player_to_season }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'When season has two existing rounds already' do
      let!(:round1) { create(:round, season: season, position: 1) }
      let!(:round2) { create(:round, season: season, position: 2) }

      before do
        round1.insert_at(1)
        round2.insert_at(2)
      end

      it 'Does not create any rankings' do
        expect { enroll_player_to_season }.to raise_error(ActiveRecord::RecordNotFound)

        expect(Ranking.all.count).to eq(0)
      end
    end
  end
end
