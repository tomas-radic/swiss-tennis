require 'rails_helper'

describe SetsDelta do
  subject(:calculation) { described_class.result_for(match: match, player: player) }

  let!(:p1) { create(:player) }
  let!(:p2) { create(:player) }

  context 'With 3 sets match' do
    let(:player) { p1 }
    let!(:match) do
      create(
        :match,
        :finished,
        player1: p1,
        player2: p2,
        players: [p1, p2],
        set1_player1_score: 4,
        set1_player2_score: 6,
        set2_player1_score: 6,
        set2_player2_score: 3,
        set3_player1_score: 6,
        set3_player2_score: 3
      )
    end

    it 'Calculates correct result' do
      expect(calculation).to eq 1
    end
  end

  context 'With 2 sets match' do
    let(:player) { p2 }
    let!(:match) do
      create(
        :match,
        :finished,
        player1: p1,
        player2: p2,
        players: [p1, p2],
        set1_player1_score: 4,
        set1_player2_score: 6,
        set2_player1_score: 1,
        set2_player2_score: 6,
        set3_player1_score: nil,
        set3_player2_score: nil
      )
    end

    it 'Calculates correct result' do
      expect(calculation).to eq 2
    end
  end

  context 'With retired player1 in the 1st set' do
    let(:player) { p2 }
    let!(:match) do
      create(
        :match,
        :finished,
        player1: p1,
        player2: p2,
        players: [p1, p2],
        retired_player: p1,
        set1_player1_score: 4,
        set1_player2_score: 5,
        set2_player1_score: nil,
        set2_player2_score: nil,
        set3_player1_score: nil,
        set3_player2_score: nil
      )
    end

    it 'Calculates correct result' do
      expect(calculation).to eq 2
    end
  end

  context 'With retired player2 in the 2nd set' do
    let(:player) { p2 }
    let!(:match) do
      create(
        :match,
        :finished,
        player1: p1,
        player2: p2,
        players: [p1, p2],
        retired_player: p2,
        set1_player1_score: 4,
        set1_player2_score: 6,
        set2_player1_score: 4,
        set2_player2_score: 1,
        set3_player1_score: nil,
        set3_player2_score: nil
      )
    end

    it 'Calculates correct result' do
      expect(calculation).to eq -1
    end
  end

  context 'When player1 refused to play the match' do
    let!(:match) do
      create(
          :match,
          :finished,
          player1: p1,
          player2: p2,
          players: [p1, p2],
          retired_player: p1,
          set1_player1_score: nil,
          set1_player2_score: nil,
          set2_player1_score: nil,
          set2_player2_score: nil,
          set3_player1_score: nil,
          set3_player2_score: nil
      )
    end

    context 'With player1' do
      let(:player) { p1 }


      it 'Calculates correct result' do
        expect(calculation).to eq -2
      end
    end

    context 'With player2' do
      let(:player) { p2 }

      it 'Calculates correct result' do
        expect(calculation).to eq 2
      end
    end
  end

  context 'With an unknown player' do
    let(:player) { create(:player) }
    let!(:match) do
      create(
        :match,
        :finished,
        player1: p1,
        player2: p2,
        players: [p1, p2],
        set1_player1_score: 6,
        set1_player2_score: 4
      )
    end

    it 'Returns nil' do
      expect(calculation).to be_nil
    end
  end
end
