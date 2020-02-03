require 'rails_helper'

describe SelectedSeason do
  subject(:calculation) { described_class.result_for(season_id: season_id) }

  context 'With seasons' do
    let!(:current_season) { create(:season, name: 'A') }
    let!(:previous_season) { create(:season, name: 'B') }

    before do
      previous_season.insert_at(1)
      current_season.insert_at(2)
    end

    context 'With given season ID' do
      let(:season_id) { previous_season.id }

      it 'Returns requested season' do
        expect(calculation).to eq previous_season
      end
    end

    context 'Without season ID' do
      let(:season_id) { nil }

      it 'Returns the most recent season' do
        expect(calculation).to eq current_season
      end
    end
  end

  context 'Without seasons' do
    let(:season_id) { nil }

    it 'Returns nil' do
      expect(calculation).to be_nil
    end
  end
end
