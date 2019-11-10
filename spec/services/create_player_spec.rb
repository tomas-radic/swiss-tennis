require 'rails_helper'

describe CreatePlayer do
  subject(:create_player) { described_class.call(attributes, season).result }

  let!(:season) { create(:season) }
  let!(:category) { create(:category) }

  context 'With valid attributes' do
    let(:attributes) do
      { first_name: 'Roger', last_name: 'Federer', category_id: category.id }
    end

    it 'Creates new player' do
      player = create_player

      expect(player.persisted?).to be true
      expect(player.first_name).to eq 'Roger'
      expect(player.last_name).to eq 'Federer'
      expect(player.category).to eq category
    end

    it 'Enrolls player to given season' do
      player = create_player

      expect(player.seasons).to include(season)
    end

    context 'When season has two existing rounds' do
      let!(:round1) { create(:round, season: season, position: 1) }
      let!(:round2) { create(:round, season: season, position: 2) }

      it 'Creates ranking for the player and last existing round of given season' do
        player = create_player

        rankings_of_season = Ranking.joins(round: :season).where(rounds: { season: season })
        expect(rankings_of_season.count).to eq 1
        expect(rankings_of_season.first.player).to eq player
      end
    end
  end

  context 'With invalid attributes' do
    let(:attributes) do
      { first_name: 'Stefanos' }
    end

    it 'Does not save the player' do
      player = create_player

      expect(player.persisted?).to be false
    end
  end
end
