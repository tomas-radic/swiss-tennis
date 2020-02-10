require 'rails_helper'

describe FinishMatch do
  subject(:finish_match) { described_class.call(match, score, attributes).result }

  shared_examples 'Setting 1st round rankings of both players as relevant' do
    it 'Sets 1st round rankings of both players as relevant' do
      match = finish_match

      expect(ranking_of_player1_round1.reload.relevant).to be true
      expect(ranking_of_player2_round1.reload.relevant).to be true
    end
  end

  let!(:season) { create(:season) }

  let!(:player1) { create(:player, seasons: [season]) }
  let!(:player2) { create(:player, seasons: [season]) }

  context 'Finishing match of 1st round' do
    let!(:round1) { create(:round, season: season, position: 1) }
    let!(:match) do
      create(:match, round: round1, player1: player1, player2: player2,
             play_date: Date.today, published: true)
    end

    let!(:ranking_of_player1_round1) do
      create(:ranking, player: player1, round: round1,
             points: 0,
             handicap: 0,
             sets_difference: 0,
             games_difference: 0,
             relevant: false
      )
    end

    let!(:ranking_of_player2_round1) do
      create(:ranking, player: player2, round: round1,
             points: 0,
             handicap: 0,
             sets_difference: 0,
             games_difference: 0,
             relevant: false
      )
    end

    shared_examples 'Player1 wins and results with 3 points and 0 handicap points' do
      it 'Adds 3 points to player1' do
        finish_match

        ranking_of_player1 = ranking_of_player1_round1.reload
        expect(ranking_of_player1.points).to eq 3
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

  context 'Finishing 2nd round match with a dummy player' do
    let!(:round1) { create(:round, season: season) }
    let!(:round2) { create(:round, season: season) }

    let!(:dummy_player) { create(:player, :dummy, seasons: [season]) }
    let!(:ranking1_of_dummy_player) { create(:ranking, round: round1, player: dummy_player) }
    let!(:ranking2_of_dummy_player) { create(:ranking, round: round2, player: dummy_player) }

    let!(:player1) { create(:player, seasons: [season]) }
    let!(:ranking1_of_player1) { create(:ranking, round: round1, player: player1, points: 3, handicap: 0, sets_difference: 2, games_difference: 7, relevant: true) }
    let!(:ranking2_of_player1) { create(:ranking, round: round2, player: player1, points: 3, handicap: 0, sets_difference: 2, games_difference: 7, relevant: true) }

    let!(:player2) { create(:player, :dummy, seasons: [season]) }
    let!(:ranking1_of_player2) { create(:ranking, round: round1, player: player2, points: 0, handicap: 3, sets_difference: -2, games_difference: -7, relevant: true) }
    let!(:ranking2_of_player2) { create(:ranking, round: round2, player: player2, points: 0, handicap: 3, sets_difference: -2, games_difference: -7, relevant: true) }

    let!(:match_of_round1) { create(:match, :finished, :published, round: round1,
                           player1: player1, player2: player2, players: [player1, player2],
                           set1_player1_score: 6, set1_player2_score: 3,
                           set2_player1_score: 6, set2_player2_score: 2,
                           winner: player1, looser: player2) }

    let!(:match) do
      create(:match, :published, round: round2, player1: player1, player2: dummy_player,
             players: [player1, dummy_player], play_date: Date.today)
    end

    let!(:attributes) do
      { attributes: { retired_player_id: dummy_player.id } }
    end

    let!(:score) do
      {}
    end

    before do
      round1.insert_at(1)
      round2.insert_at(2)
    end

    it 'Sets match winner and looser' do
      match = finish_match

      expect(match.winner).to eq(player1)
      expect(match.looser).to eq(dummy_player)
    end

    it 'Updates round2 ranking of player1 and handicap of player2' do
      finish_match

      expect(ranking2_of_player1.reload).to have_attributes(
                                                points: 6,
                                                handicap: 0,
                                                sets_difference: 4,
                                                games_difference: 19,
                                                relevant: true
                                            )

      expect(ranking2_of_player2.reload).to have_attributes(
                                                points: 0,
                                                handicap: 6,
                                                sets_difference: -2,
                                                games_difference: -7,
                                                relevant: true
                                            )
    end

    it 'Does not update ranking of dummy player' do
      finish_match

      expect(ranking2_of_dummy_player.reload).to have_attributes(
                                                     points: 0,
                                                     handicap: 0,
                                                     sets_difference: 0,
                                                     games_difference: 0,
                                                     relevant: false
                                                 )
    end

    it 'Does not update 1st round rankings' do
      finish_match

      expect(ranking1_of_player1.reload).to have_attributes(
                                                points: 3,
                                                handicap: 0,
                                                sets_difference: 2,
                                                games_difference: 7,
                                                relevant: true
                                            )

      expect(ranking1_of_player2.reload).to have_attributes(
                                                points: 0,
                                                handicap: 3,
                                                sets_difference: -2,
                                                games_difference: -7,
                                                relevant: true
                                            )

      expect(ranking1_of_dummy_player.reload).to have_attributes(
                                                     points: 0,
                                                     handicap: 0,
                                                     sets_difference: 0,
                                                     games_difference: 0,
                                                     relevant: false
                                                 )
    end
  end

  context 'Finishing match of 3rd round when there are 5 rounds existing' do
    # Players 
    let!(:playerA) { create(:player, first_name: 'Player', last_name: 'A') }
    let!(:playerB) { create(:player, first_name: 'Player', last_name: 'B') }
    let!(:playerC) { create(:player, first_name: 'Player', last_name: 'C') }
    let!(:playerD) { create(:player, first_name: 'Player', last_name: 'D') }
    let!(:playerE) { create(:player, first_name: 'Player', last_name: 'E') }
    let!(:playerF) { create(:player, first_name: 'Player', last_name: 'F') }

    # Round 1
    let!(:round1) { create(:round, position: 1, season: season) }
    let!(:match1_AB) { create(:match, :finished, round: round1, player1: playerA, player2: playerB, players: [playerA, playerB], retired_player: playerB, set1_player1_score: nil, set1_player2_score: nil) } # this match has not been even started
    let!(:match1_CD) { create(:match, :finished, round: round1, player1: playerC, player2: playerD, players: [playerC, playerD]) }
    let!(:match1_EF) { create(:match, :finished, round: round1, player1: playerE, player2: playerF, players: [playerE, playerF]) }
    let!(:ranking1A) { create(:ranking, round: round1, player: playerA, handicap: 1) }
    let!(:ranking1B) { create(:ranking, round: round1, player: playerB, handicap: 1) }
    let!(:ranking1C) { create(:ranking, round: round1, player: playerC, handicap: 1) }
    let!(:ranking1D) { create(:ranking, round: round1, player: playerD, handicap: 1) }
    let!(:ranking1E) { create(:ranking, round: round1, player: playerE, handicap: 1) }
    let!(:ranking1F) { create(:ranking, round: round1, player: playerF, handicap: 1) }

    # Round 2
    let!(:round2) { create(:round, position: 2, season: season) }
    let!(:match2_AC) { create(:match, :finished, round: round2, player1: playerA, player2: playerC, players: [playerA, playerC], retired_player: playerA, set1_player1_score: 0, set1_player2_score: 6) } # player retired but match has been started
    let!(:match2_BE) { create(:match, :finished, round: round2, player1: playerB, player2: playerE, players: [playerB, playerE]) }
    let!(:match2_DF) { create(:match, :finished, round: round2, player1: playerD, player2: playerF, players: [playerD, playerF]) }
    let!(:ranking2A) { create(:ranking, round: round2, player: playerA, handicap: 2) }
    let!(:ranking2B) { create(:ranking, round: round2, player: playerB, handicap: 2) }
    let!(:ranking2C) { create(:ranking, round: round2, player: playerC, handicap: 2) }
    let!(:ranking2D) { create(:ranking, round: round2, player: playerD, handicap: 2) }
    let!(:ranking2E) { create(:ranking, round: round2, player: playerE, handicap: 2) }
    let!(:ranking2F) { create(:ranking, round: round2, player: playerF, handicap: 2) }

    # Round 3
    let!(:round3) { create(:round, position: 3, season: season) }
    let!(:match3_AD) { create(:match, round: round3, player1: playerA, player2: playerD, players: [playerA, playerD]) }
    let!(:match3_BF) { create(:match, round: round3, player1: playerB, player2: playerF, players: [playerB, playerF]) }
    let!(:match3_CE) { create(:match, round: round3, player1: playerC, player2: playerE, players: [playerC, playerE]) }
    let!(:ranking3A) { create(:ranking, round: round3, player: playerA, handicap: 3) }
    let!(:ranking3B) { create(:ranking, round: round3, player: playerB, handicap: 3) }
    let!(:ranking3C) { create(:ranking, round: round3, player: playerC, handicap: 3) }
    let!(:ranking3D) { create(:ranking, round: round3, player: playerD, handicap: 3) }
    let!(:ranking3E) { create(:ranking, round: round3, player: playerE, handicap: 3) }
    let!(:ranking3F) { create(:ranking, round: round3, player: playerF, handicap: 3) }

    # Round 4
    let!(:round4) { create(:round, position: 4, season: season) }
    let!(:match4_AE) { create(:match, round: round4, player1: playerA, player2: playerE, players: [playerA, playerE]) }
    let!(:match4_BD) { create(:match, round: round4, player1: playerB, player2: playerD, players: [playerB, playerD]) }
    let!(:match4_CF) { create(:match, round: round4, player1: playerC, player2: playerF, players: [playerC, playerF]) }
    let!(:ranking4A) { create(:ranking, round: round4, player: playerA, handicap: 4) }
    let!(:ranking4B) { create(:ranking, round: round4, player: playerB, handicap: 4) }
    let!(:ranking4C) { create(:ranking, round: round4, player: playerC, handicap: 4) }
    let!(:ranking4D) { create(:ranking, round: round4, player: playerD, handicap: 4) }
    let!(:ranking4E) { create(:ranking, round: round4, player: playerE, handicap: 4) }
    let!(:ranking4F) { create(:ranking, round: round4, player: playerF, handicap: 4) }

    # Round 5
    let!(:round5) { create(:round, position: 5, season: season) }
    let!(:match5_AF) { create(:match, round: round5, player1: playerA, player2: playerF, players: [playerA, playerF]) }
    let!(:match5_BC) { create(:match, round: round5, player1: playerB, player2: playerC, players: [playerB, playerC]) }
    let!(:match5_DE) { create(:match, round: round5, player1: playerD, player2: playerE, players: [playerD, playerE]) }
    let!(:ranking5A) { create(:ranking, round: round5, player: playerA, handicap: 5) }
    let!(:ranking5B) { create(:ranking, round: round5, player: playerB, handicap: 5) }
    let!(:ranking5C) { create(:ranking, round: round5, player: playerC, handicap: 5) }
    let!(:ranking5D) { create(:ranking, round: round5, player: playerD, handicap: 5) }
    let!(:ranking5E) { create(:ranking, round: round5, player: playerE, handicap: 5) }
    let!(:ranking5F) { create(:ranking, round: round5, player: playerF, handicap: 5) }

    let!(:attributes) do
      {}
    end

    before do
      round1.insert_at(1)
      round2.insert_at(2)
      round3.insert_at(3)
      round4.insert_at(4)
      round5.insert_at(5)
    end


    describe 'Finishing 3rd round match of playerA and playerD' do
      let!(:match) { match3_AD }

      context 'Match has been played and result was 2:0' do
        let!(:score) do
          {
              set1_player1: 6,
              set1_player2: 3,
              set2_player1: 6,
              set2_player2: 2
          }
        end

        it 'Updates rankings of 3rd round and all later rounds for given players and their opponents from previous rounds' do
          finish_match

          # 3rd round rankings
          expect(ranking3A.reload).to have_attributes(points: 3, handicap: 3, sets_difference: 2, games_difference: 7, relevant: true)
          expect(ranking3D.reload).to have_attributes(points: 0, handicap: 3 + 3, sets_difference: -2, games_difference: -7, relevant: true)

          expect(ranking3B.reload).to have_attributes(handicap: 3, relevant: false) # not updated since playerB refused to play against playerA in 1st round
          expect(ranking3C.reload.handicap).to eq(3 + 3) # as an opponent of playerA in 2nd round
          expect(ranking3E.reload.handicap).to eq(3)
          expect(ranking3F.reload.handicap).to eq(3)

          # 4th round rankings
          expect(ranking4A.reload).to have_attributes(points: 3, handicap: 4, sets_difference: 2, games_difference: 7, relevant: true)
          expect(ranking4D.reload).to have_attributes(points: 0, handicap: 4 + 3, sets_difference: -2, games_difference: -7, relevant: true)

          expect(ranking4B.reload).to have_attributes(handicap: 4, relevant: false) # not updated since playerB refused to play against playerA in 1st round
          expect(ranking4C.reload.handicap).to eq(4 + 3)
          expect(ranking4E.reload.handicap).to eq(4)
          expect(ranking4F.reload.handicap).to eq(4)

          # 5th round rankings
          expect(ranking5A.reload).to have_attributes(points: 3, handicap: 5, sets_difference: 2, games_difference: 7, relevant: true)
          expect(ranking5D.reload).to have_attributes(points: 0, handicap: 5 + 3, sets_difference: -2, games_difference: -7, relevant: true)

          expect(ranking5B.reload).to have_attributes(handicap: 5, relevant: false) # not updated since playerB refused to play against playerA in 1st round
          expect(ranking5C.reload.handicap).to eq(5 + 3)
          expect(ranking5E.reload.handicap).to eq(5)
          expect(ranking5F.reload.handicap).to eq(5)
        end

        it 'Does not update any rankings of previous rounds' do
          finish_match

          # 1st round rankings
          expect(ranking1A.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1B.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1C.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1D.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1E.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1F.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)

          # 2nd round rankings
          expect(ranking2A.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2B.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2C.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2D.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2E.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2F.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
        end
      end

      context 'Match has been played and result was 1:2' do
        let!(:score) do
          {
              set1_player1: 2,
              set1_player2: 6,
              set2_player1: 6,
              set2_player2: 4,
              set3_player1: 1,
              set3_player2: 6
          }
        end

        it 'Updates rankings of 3rd round and all later rounds for given players and their opponents from previous rounds' do
          finish_match

          # 3rd round rankings
          expect(ranking3A.reload).to have_attributes(points: 1, handicap: 3 + 2, sets_difference: -1, games_difference: -7, relevant: true)
          expect(ranking3D.reload).to have_attributes(points: 2, handicap: 3 + 1, sets_difference: 1, games_difference: 7, relevant: true)

          expect(ranking3B.reload.handicap).to eq(3)
          expect(ranking3C.reload.handicap).to eq(3 + 2 + 1) # as an opponent of playerA in 2nd round and playerD in 1st round
          expect(ranking3E.reload.handicap).to eq(3)
          expect(ranking3F.reload.handicap).to eq(3 + 2) # as an opponent of playerD in 2nd round

          # 4th round rankings
          expect(ranking4A.reload).to have_attributes(points: 1, handicap: 4 + 2, sets_difference: -1, games_difference: -7, relevant: true)
          expect(ranking4D.reload).to have_attributes(points: 2, handicap: 4 + 1, sets_difference: 1, games_difference: 7, relevant: true)

          expect(ranking4B.reload.handicap).to eq(4)
          expect(ranking4C.reload.handicap).to eq(4 + 2 + 1) # as an opponent of playerA in 2nd round and playerD in 1st round
          expect(ranking4E.reload.handicap).to eq(4)
          expect(ranking4F.reload.handicap).to eq(4 + 2) # as an opponent of playerD in 2nd round

          # 5th round rankings
          expect(ranking5A.reload).to have_attributes(points: 1, handicap: 5 + 2, sets_difference: -1, games_difference: -7, relevant: true)
          expect(ranking5D.reload).to have_attributes(points: 2, handicap: 5 + 1, sets_difference: 1, games_difference: 7, relevant: true)

          expect(ranking5B.reload.handicap).to eq(5)
          expect(ranking5C.reload.handicap).to eq(5 + 2 + 1) # as an opponent of playerA in 2nd round and playerD in 1st round
          expect(ranking5E.reload.handicap).to eq(5)
          expect(ranking5F.reload.handicap).to eq(5 + 2) # as an opponent of playerD in 2nd round
        end

        it 'temp' do
          finish_match

          expect(ranking3C.reload.handicap).to eq(3 + 2 + 1)
        end

        it 'Does not update any rankings of previous rounds' do
          finish_match

          # 1st round rankings
          expect(ranking1A.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1B.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1C.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1D.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1E.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking1F.reload).to have_attributes(points: 0, handicap: 1, sets_difference: 0, games_difference: 0, relevant: false)

          # 2nd round rankings
          expect(ranking2A.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2B.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2C.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2D.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2E.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
          expect(ranking2F.reload).to have_attributes(points: 0, handicap: 2, sets_difference: 0, games_difference: 0, relevant: false)
        end
      end
    end
  end
end
