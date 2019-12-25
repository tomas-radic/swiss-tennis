require 'rails_helper'

describe NumberOfWonGames do
  subject(:calculation) { described_class.result_for(match: match, player: player) }

  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }

  context 'Without retirements' do
    context 'With two sets match' do
      let!(:match) do
        create(
            :match,
            player1: player1, player2: player2, players: [player1, player2],
            set1_player1_score: 3, set1_player2_score: 6,
            set2_player1_score: 4, set2_player2_score: 6
        )
      end

      context 'With player1' do
        let!(:player) { player1 }

        it 'Returns 7' do
          expect(calculation).to eq(7)
        end
      end

      context 'With player2' do
        let!(:player) { player2 }

        it 'Returns 12' do
          expect(calculation).to eq(12)
        end
      end
    end

    context 'With 3 sets match' do
      let!(:match) do
        create(
            :match,
            player1: player1, player2: player2, players: [player1, player2],
            set1_player1_score: 3, set1_player2_score: 6,
            set2_player1_score: 6, set2_player2_score: 2,
            set3_player1_score: 7, set3_player2_score: 6
        )
      end

      context 'With player1' do
        let!(:player) { player1 }

        it 'Returns 16' do
          expect(calculation).to eq(16)
        end
      end

      context 'With player2' do
        let!(:player) { player2 }

        it 'Returns 14' do
          expect(calculation).to eq(14)
        end
      end
    end
  end

  context 'When player1 retires in 1st set' do
    let!(:retired_player) { player1 }
    let!(:match) do
      create(
          :match,
          player1: player1, player2: player2, players: [player1, player2],
          retired_player: retired_player,
          set1_player1_score: 3, set1_player2_score: 5
      )
    end

    context 'With player1' do
      let!(:player) { player1 }

      it 'Returns 3' do
        expect(calculation).to eq(3)
      end
    end

    context 'With player2' do
      let!(:player) { player2 }

      it 'Returns 5' do
        expect(calculation).to eq(5)
      end
    end
  end

  context 'When player2 retires in 2nd set' do
    let!(:retired_player) { player2 }


    let!(:match) do
      create(
          :match,
          player1: player1, player2: player2, players: [player1, player2],
          retired_player: retired_player,
          set1_player1_score: 6, set1_player2_score: 1,
          set2_player1_score: 3, set2_player2_score: 3
      )
    end

    context 'With player1' do
      let!(:player) { player1 }

      it 'Returns 9' do
        expect(calculation).to eq(9)
      end
    end

    context 'With player2' do
      let!(:player) { player2 }

      it 'Returns 4' do
        expect(calculation).to eq(4)
      end
    end
  end

  context 'When player1 retires in 3rd set' do
    let!(:retired_player) { player1 }
    let!(:match) do
      create(
          :match,
          player1: player1, player2: player2, players: [player1, player2],
          retired_player: retired_player,
          set1_player1_score: 2, set1_player2_score: 6,
          set2_player1_score: 6, set2_player2_score: 3,
          set3_player1_score: 4, set3_player2_score: 3
      )
    end

    context 'With player1' do
      let!(:player) { player1 }

      it 'Returns 12' do
        expect(calculation).to eq(12)
      end
    end

    context 'With player2' do
      let!(:player) { player2 }

      it 'Returns 12' do
        expect(calculation).to eq(12)
      end
    end
  end

  context 'When player2 even refuses to start playing the match' do
    let!(:retired_player) { player2 }
    let!(:match) do
      create(
          :match,
          player1: player1, player2: player2, players: [player1, player2],
          retired_player: retired_player
      )
    end

    context 'With player1' do
      let!(:player) { player1 }

      it 'Returns 0' do
        expect(calculation).to eq(0)
      end
    end

    context 'With player2' do
      let!(:player) { player2 }

      it 'Returns 0' do
        expect(calculation).to eq(0)
      end
    end
  end
end
