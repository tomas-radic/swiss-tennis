require 'rails_helper'

describe MatchDecorator do
  let(:match) { create(:match, set1_player1_score: 6, set1_player2_score: 4,
      set2_player1_score: 6, set2_player2_score: 3, set3_player1_score: 6) }

  describe 'score' do
    subject(:score) { described_class.new(match).score }

    it 'Returns match score string' do
      expect(score).to eq '6:4 | 6:3'
    end
  end

  describe 'set1' do
    subject(:set1) { described_class.new(match).set1 }

    it 'Returns set1 score string' do
      expect(set1).to eq '6:4'
    end
  end

  describe 'set2' do
    subject(:set2) { described_class.new(match).set2 }

    it 'Returns set2 score string' do
      expect(set2).to eq '6:3'
    end
  end

  describe 'set3' do
    subject(:set3) { described_class.new(match).set3 }

    it 'Returns set3 score string' do
      expect(set3).to eq ''
    end
  end
end
