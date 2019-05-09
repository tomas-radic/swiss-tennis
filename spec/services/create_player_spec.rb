require 'rails_helper'

describe CreatePlayer do
  subject(:create_player) { described_class.call(attributes, season).result }

  let!(:season) { create(:season) }
  let!(:category) { create(:category) }

  context 'With valid attributes' do
    let(:attributes) do
      { first_name: 'Stefanos', last_name: 'Tsitsipas', category_id: category.id }
    end

    it 'Creates new player' do
      player = create_player

      expect(player.persisted?).to be true
      expect(player.first_name).to eq 'Stefanos'
      expect(player.last_name).to eq 'Tsitsipas'
      expect(player.category).to eq category
    end

    it 'Enrolls player to given season' do
      player = create_player

      expect(player.seasons).to include(season)
    end

    context 'When season has 1 closed and 1 open round' do
      let!(:round1) { create(:round, :closed, season: season) }
      let!(:round2) { create(:round, season: season) }

      it 'Creates ranking for the created player in the open round' do
        player = create_player

        expect(player.rankings.count).to eq 1
        expect(player.rankings.find_by(round: round2)).to have_attributes(
          points: 0,
          handicap: 0,
          sets_difference: 0,
          games_difference: 0,
          relevant: false
        )
      end
    end

    context 'When season has 2 closed rounds' do
      it 'Does not create ranking for created player' do
        expect { create_player }.not_to change(Ranking, :count)
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
