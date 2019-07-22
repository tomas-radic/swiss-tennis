require 'rails_helper'

describe SelectedRound do

  subject(:calculation) { described_class.result_for(season, round_id: round_id) }

  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season, position: 1) }
  let!(:round2) { create(:round, season: season, position: 2) }
  let!(:round3) { create(:round, season: season, position: 3) }

  context 'With requested round' do
    context 'When requested round exists' do
      let(:round_id) { round1.id }

      it 'Returns requested round' do
        expect(calculation).to eq round1
      end
    end

    context 'When requested round does not exist' do
      let!(:match) { create(:match, round: round2, published: true) }
      let(:round_id) { 'abc123' }

      it 'Returns latest round that has any public matches' do
        expect(calculation).to eq round2
      end
    end

    context 'Without public matches in any of rounds' do
      let(:round_id) { nil }

      it 'Returns latest round' do
        expect(calculation).to eq round3
      end
    end
  end

  context 'Without requested round' do
    subject(:calculation) { described_class.result_for(season) }

    let!(:match) { create(:match, round: round2, published: true) }

    it 'Returns latest round that has any public matches' do
      expect(calculation).to eq round2
    end
  end
end
