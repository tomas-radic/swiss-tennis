require 'rails_helper'

describe SwapMatchPlayers do
  subject(:service) { described_class.call(match) }

  context 'With unfinished match' do
    let!(:match) { create(:match) }

    it 'Swaps the players' do
      p1 = match.player1
      p2 = match.player2

      service
      expect(match.player1).to eq p2
      expect(match.player2).to eq p1
    end
  end

  context 'With finished match' do
    let!(:match) { create(:match, :finished) }

    it 'Does not swap the players' do
      p1 = match.player1
      p2 = match.player2

      service
      expect(match.player1).to eq p1
      expect(match.player2).to eq p2
    end
  end
end
