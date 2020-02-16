require 'rails_helper'

describe NumberOfWonSets do
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

      context 'With player1 who lost the match with 0:2 score' do
        let!(:player) { player1 }

        it 'Returns 0' do
          expect(calculation).to eq(0)
        end
      end

      context 'With player2 who won the match with 2:0 score' do
        let!(:player) { player2 }

        it 'Returns 2' do
          expect(calculation).to eq(2)
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

      context 'With player1 who won the match with 2:1 score' do
        let!(:player) { player1 }

        it 'Returns 2' do
          expect(calculation).to eq(2)
        end
      end

      context 'With player2 who lost the match with 1:2 score' do
        let!(:player) { player2 }

        it 'Returns 1' do
          expect(calculation).to eq(1)
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
          set1_player1_score: 5, set1_player2_score: 6
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

  context "When player1 retires right after the 1st set" do
    let!(:retired_player) { player1 }
    let!(:match) do
      create(
          :match,
          player1: player1, player2: player2, players: [player1, player2],
          retired_player: retired_player,
          set1_player1_score: 3, set1_player2_score: 6
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
        expect(calculation).to eq(1)
      end
    end
  end

  context 'When player2 retires in 2nd set' do
    let!(:retired_player) { player2 }

    context 'And lost the 1st set' do
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

        it 'Returns 1' do
          expect(calculation).to eq(1)
        end
      end

      context 'With player2' do
        let!(:player) { player2 }

        it 'Returns 0' do
          expect(calculation).to eq(0)
        end
      end
    end

    context 'And won the first set' do
      let!(:match) do
        create(
            :match,
            player1: player1, player2: player2, players: [player1, player2],
            retired_player: retired_player,
            set1_player1_score: 2, set1_player2_score: 6,
            set2_player1_score: 3, set2_player2_score: 3
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

        it 'Returns 1' do
          expect(calculation).to eq(1)
        end
      end
    end
  end

  context 'When player2 retires right after 2nd set' do
    let!(:retired_player) { player2 }

    let!(:match) do
      create(
          :match,
          player1: player1, player2: player2, players: [player1, player2],
          retired_player: retired_player,
          set1_player1_score: 6, set1_player2_score: 3,
          set2_player1_score: 6, set2_player2_score: 7
      )
    end

    context 'With player1' do
      let!(:player) { player1 }

      it 'Returns 1' do
        expect(calculation).to eq(1)
      end
    end

    context 'With player2' do
      let!(:player) { player2 }

      it 'Returns 0' do
        expect(calculation).to eq(1)
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

      it 'Returns 1' do
        expect(calculation).to eq(1)
      end
    end

    context 'With player2' do
      let!(:player) { player2 }

      it 'Returns 1' do
        expect(calculation).to eq(1)
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
