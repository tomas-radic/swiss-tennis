require 'rails_helper'

describe FinishMatch2 do
  subject(:finish_match) { described_class.call(match, score, attributes).result }

  shared_examples 'Setting 1st round rankings of both players as relevant' do
    it 'Sets 1st round rankings of both players as relevant' do
      match = finish_match

      expect(ranking_of_player1_round1.reload.relevant).to be true
      expect(ranking_of_player2_round1.reload.relevant).to be true
    end
  end

  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season, position: 1) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }

  let!(:ranking_of_player1_round1) do
    create(:ranking, player: player1, round: round1,
           points: 0,
           toss_points: 0,
           handicap: 0,
           sets_difference: 0,
           games_difference: 0,
           relevant: false
    )
  end

  let!(:ranking_of_player2_round1) do
    create(:ranking, player: player2, round: round1,
           points: 0,
           toss_points: 0,
           handicap: 0,
           sets_difference: 0,
           games_difference: 0,
           relevant: false
    )
  end

  let!(:match) do
    create(:match, round: round1, player1: player1, player2: player2,
           play_date: Date.today, published: true)
  end

  context 'Finishing match of 1st round' do

    shared_examples 'Player1 wins and results with 3 points and 0 handicap points' do
      it 'Adds 3 points to player1' do
        finish_match

        ranking_of_player1 = ranking_of_player1_round1.reload
        expect(ranking_of_player1.points).to eq 3
        expect(ranking_of_player1.toss_points).to eq 3
      end

      it "Does not add any points to handicap of player1" do
        finish_match

        expect(ranking_of_player1_round1.reload.handicap).to eq 0
      end
    end

    shared_examples 'Player2 looses and results with 0 points and 3 handicap points' do
      it 'Does not add any points to player2' do
        finish_match

        ranking_of_player2 = ranking_of_player2_round1.reload
        expect(ranking_of_player2.points).to eq 0
        expect(ranking_of_player2.toss_points).to eq 0
      end

      it 'Adds 3 points to handicap of player2' do
        finish_match

        expect(ranking_of_player2_round1.reload.handicap).to eq 3
      end
    end

    shared_examples 'Player1 looses and results with 1 point and 2 handicap points' do
      it 'Adds 1 point to player1' do
        finish_match

        ranking_of_player1 = ranking_of_player1_round1.reload
        expect(ranking_of_player1.points).to eq 1
        expect(ranking_of_player1.toss_points).to eq 1
      end

      it 'Adds 2 points to handicap of player1' do
        finish_match

        expect(ranking_of_player1_round1.reload.handicap).to eq 2
      end
    end

    shared_examples 'Player2 wins and results with 2 points and 1 handicap point' do
      it 'Adds 2 points to player2' do
        finish_match

        ranking_of_player2 = ranking_of_player2_round1.reload
        expect(ranking_of_player2.points).to eq 2
        expect(ranking_of_player2.toss_points).to eq 2
      end

      it "Adds 1 point to handicap of player2" do
        finish_match

        expect(ranking_of_player2_round1.reload.handicap).to eq 1
      end
    end

    context 'When match is finished without retirements' do
      let!(:attributes) do
        {
            attributes: {
                note: 'Changed note.',
                play_date: Date.yesterday.to_s,
                published: false
            }
        }
      end

      context 'And player1 wins with 2:0 score' do
        let!(:score) do
          {
              set1_player1: 6,
              set1_player2: 3,
              set2_player1: 6,
              set2_player2: 2
          }
        end

        it 'Returns finished match' do
          finished_match = finish_match

          expect(finished_match).to eq match
          expect(finished_match.finished?).to be(true)
        end

        it 'Updates match attributes - note only' do
          match = finish_match

          expect(match.note).to eq(attributes[:attributes][:note])
          expect(match.play_date).not_to eq(Date.parse(attributes[:attributes][:play_date]))
          expect(match.published?).to be(true)
        end


        it 'Sets match winner and looser' do
          match = finish_match

          expect(match.winner).to eq(player1)
          expect(match.looser).to eq(player2)
        end

        it_behaves_like 'Setting 1st round rankings of both players as relevant'
        it_behaves_like 'Player1 wins and results with 3 points and 0 handicap points'
        it_behaves_like 'Player2 looses and results with 0 points and 3 handicap points'


        it 'Updates sets difference of both players' do
          finish_match

          expect(ranking_of_player1_round1.reload.sets_difference).to eq 2
          expect(ranking_of_player2_round1.reload.sets_difference).to eq -2
        end

        it 'Updates games difference of both players' do
          finish_match

          expect(ranking_of_player1_round1.reload.games_difference).to eq 7
          expect(ranking_of_player2_round1.reload.games_difference).to eq -7
        end
      end

      context 'And player1 looses with 1:2 score' do
        let!(:score) do
          {
              set1_player1: 6,
              set1_player2: 3,
              set2_player1: 3,
              set2_player2: 6,
              set3_player1: 2,
              set3_player2: 6
          }
        end

        it_behaves_like 'Player1 looses and results with 1 point and 2 handicap points'
        it_behaves_like 'Player2 wins and results with 2 points and 1 handicap point'

        it 'Updates sets difference of both players' do
          finish_match

          expect(ranking_of_player1_round1.reload.sets_difference).to eq -1
          expect(ranking_of_player2_round1.reload.sets_difference).to eq 1
        end

        it 'Updates games difference of both players' do
          finish_match

          expect(ranking_of_player1_round1.reload.games_difference).to eq -4
          expect(ranking_of_player2_round1.reload.games_difference).to eq 4
        end
      end
    end

    context 'When player2 gave up during the match while not winning any sets' do
      let!(:attributes) do
        { attributes: { retired_player_id: player2.id } }
      end

      let!(:score) do
        {
            set1_player1: 6,
            set1_player2: 3,
            set2_player1: 3,
            set2_player2: 1
        }
      end

      it 'Sets match winner and looser' do
        match = finish_match

        expect(match.winner).to eq(player1)
        expect(match.looser).to eq(player2)
      end

      it 'Sets player2 as a retired player' do
        match = finish_match

        expect(match.retired_player).to eq(player2)
      end

      it_behaves_like 'Setting 1st round rankings of both players as relevant'
      it_behaves_like 'Player1 wins and results with 3 points and 0 handicap points'
      it_behaves_like 'Player2 looses and results with 0 points and 3 handicap points'

      it 'Updates sets difference of both players' do
        finish_match

        expect(ranking_of_player1_round1.reload.sets_difference).to eq 1
        expect(ranking_of_player2_round1.reload.sets_difference).to eq -1
      end

      it 'Updates games difference of both players' do
        finish_match

        expect(ranking_of_player1_round1.reload.games_difference).to eq 5
        expect(ranking_of_player2_round1.reload.games_difference).to eq -5
      end
    end

    context 'When player1 won a set but retired later' do
      let!(:attributes) do
        { attributes: { retired_player_id: player1.id } }
      end

      let!(:score) do
        {
            set1_player1: 6,
            set1_player2: 3,
            set2_player1: 2,
            set2_player2: 6,
            set3_player1: 1,
            set3_player2: 4
        }
      end

      it 'Sets match winner and looser' do
        match = finish_match

        expect(match.winner).to eq(player2)
        expect(match.looser).to eq(player1)
      end

      it 'Sets player1 as a retired player' do
        match = finish_match

        expect(match.retired_player).to eq(player1)
      end

      it_behaves_like 'Setting 1st round rankings of both players as relevant'
      it_behaves_like 'Player1 looses and results with 1 point and 2 handicap points'
      it_behaves_like 'Player2 wins and results with 2 points and 1 handicap point'


      it 'Updates sets difference of both players' do
        finish_match

        expect(ranking_of_player1_round1.reload.sets_difference).to eq 0
        expect(ranking_of_player2_round1.reload.sets_difference).to eq 0
      end

      it 'Updates games difference of both players' do
        finish_match

        expect(ranking_of_player1_round1.reload.games_difference).to eq -4
        expect(ranking_of_player2_round1.reload.games_difference).to eq 4
      end
    end

    context 'When player2 even refused to start playing the match' do
      let!(:attributes) do
        { attributes: { retired_player_id: player2.id } }
      end

      let!(:score) do
        {}
      end

      it 'Sets match winner and looser' do
        match = finish_match

        expect(match.winner).to eq(player1)
        expect(match.looser).to eq(player2)
      end

      it 'Sets player2 as a retired player' do
        match = finish_match

        expect(match.retired_player).to eq(player2)
      end

      it 'Sets ranking of player1 as relevant' do
        finish_match

        expect(ranking_of_player1_round1.reload.relevant).to be(true)
      end

      it 'Does not set ranking of player2 as relevant' do
        finish_match

        expect(ranking_of_player2_round1.reload.relevant).to be(false)
      end

      it 'Does not add any points to handicap of player2' do
        match = finish_match

        expect(ranking_of_player2_round1.reload.handicap).to eq(0)
      end

      it_behaves_like 'Player1 wins and results with 3 points and 0 handicap points'

      it 'Adds 2 won sets and 12 won games to player1' do
        finish_match

        ranking_of_player1 = ranking_of_player1_round1.reload
        expect(ranking_of_player1.sets_difference).to eq(2)
        expect(ranking_of_player1.games_difference).to eq(12)
      end

      it 'Adds 2 lost sets and 12 lost games to player2' do
        finish_match

        ranking_of_player2 = ranking_of_player2_round1.reload
        expect(ranking_of_player2.sets_difference).to eq(-2)
        expect(ranking_of_player2.games_difference).to eq(-12)
      end
    end
  end

  context 'Finishing match of 3rd round when there are 5 rounds existing' do

=begin
  Round 1
  player1 - player2
  player3 - player4
  player5 - player6

  Round 2
  player1 - player3
  player2 - player5
  player4 - player6

  Round 3
  player1 - player4
  player2 - player6
  player3 - player5

  Round 4
  player1 - player5
  player2 - player4
  player3 - player6

  Round 5
  player1 - player6
  player2 - player3
  player4 - player5
=end

    it "Updates winner's 3rd round ranking correctly"

    it "Updates looser's 3rd round ranking correctly"

    it "Updates 3rd round rankings of winner's previous opponents correctly"

    it "Does not update any other rankings"

    context 'And there are rankings for later rounds already existing' do
      it "Updates winner's later rounds rankings correctly"

      it "Updates looser's later rounds rankings correctly"

      it "Updates winner's opponents later rounds rankings correctly"
    end
  end
end
