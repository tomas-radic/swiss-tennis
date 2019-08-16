require 'rails_helper'

describe FinishMatch do
  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:player1) { create(:player, last_name: 'Player1') }
  let!(:player2) { create(:player, last_name: 'Player2') }

  let!(:opponent_r1_p1) { create(:player) } # opponent of player1 in 1st round
  let!(:opponent_r1_p2) { create(:player) } # opponent of player2 in 1st round

  let!(:ranking11) { create(:ranking, round: round1, player: player1, points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4) }
  let!(:ranking12) { create(:ranking, round: round1, player: player2, points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2) }
  let!(:ranking21) { create(:ranking, round: round2, player: player1, points: 0, toss_points: 0, handicap: 1, sets_difference: 3, games_difference: 4) }
  let!(:ranking22) { create(:ranking, round: round2, player: player2, points: 2, toss_points: 3, handicap: 0, sets_difference: -2, games_difference: 2) }
  let!(:ranking_r1_of_p1_opponent_from_r1) { create(:ranking, round: round1, player: opponent_r1_p1, points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true) }
  let!(:ranking_r2_of_p1_opponent_from_r1) { create(:ranking, round: round2, player: opponent_r1_p1, points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true) }
  let!(:ranking_r1_of_p2_opponent_from_r1) { create(:ranking, round: round1, player: opponent_r1_p2, points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false) }
  let!(:ranking_r2_of_p2_opponent_from_r1) { create(:ranking, round: round2, player: opponent_r1_p2, points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false) }
  # NOTE: before finishing match in round 2, rankings are copies of previous rankings from round 1

  let!(:match) { create(:match, :draft, round: round2, player1: player1, player2: player2, players: [player1, player2], note: 'Original note') }

  # Previous matches of player1 and player2
  let!(:match_r1_p1) { create(:match, :finished, round: round1, player1: player1, player2: opponent_r1_p1, players: [player1, opponent_r1_p1]) }
  let!(:match_r1_p2) { create(:match, :finished, round: round1, player1: opponent_r1_p2, player2: player2, players: [opponent_r1_p2, player2]) }
  let(:attributes) do
    {
      attributes: { note: 'Changed note' }
    }
  end

  context 'Without retirement' do
    subject(:finish_match) { described_class.call(match, score, attributes).result }

    context 'With 3 sets match' do
      let(:score) do
        {
          set1_player1: 6,
          set1_player2: 3,
          set2_player1: 4,
          set2_player2: 6,
          set3_player1: 7,
          set3_player2: 5
        }
      end

      it 'Sets winner and returns the finished match' do
        match = finish_match

        expect(match.winner).to eq player1
      end

      it 'Sets score for the match' do
        match = finish_match

        expect(match.set1_player1_score).to eq 6
        expect(match.set1_player2_score).to eq 3
        expect(match.set2_player1_score).to eq 4
        expect(match.set2_player2_score).to eq 6
        expect(match.set3_player1_score).to eq 7
        expect(match.set3_player2_score).to eq 5
      end

      it 'Updates rankings of current round for both players and previous opponents' do
        finish_match

        expect(ranking21.reload).to have_attributes(
            points: 1, toss_points: 1, handicap: 3, sets_difference: 4, games_difference: 7, relevant: true)
        expect(ranking22.reload).to have_attributes(
            points: 2, toss_points: 2, handicap: 1, sets_difference: -3, games_difference: -1, relevant: true)
        expect(ranking_r2_of_p1_opponent_from_r1.reload).to have_attributes(
            points: 1, toss_points: 1, handicap: 3, sets_difference: 1, games_difference: 5, relevant: true)
      end

      it 'Does not update other rankings' do
        finish_match

        expect(ranking11.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4, relevant: false
        )
        expect(ranking12.reload).to have_attributes(
          points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false
        )
        expect(ranking_r1_of_p1_opponent_from_r1.reload).to have_attributes(
          points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true
        )
        expect(ranking_r1_of_p2_opponent_from_r1.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false
        )
        expect(ranking_r2_of_p2_opponent_from_r1.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false
        )
      end

      it 'Sets match finished and published' do
        match = finish_match

        expect(match.finished?).to be true
        expect(match.published?).to be true
      end

      it 'Updates attributes' do
        match = finish_match

        expect(match.note).to eq 'Changed note'
      end
    end

    context 'With 2 sets match' do
      context 'And correct score' do
        let(:score) do
          {
            set1_player1: 1,
            set1_player2: 6,
            set2_player1: 2,
            set2_player2: 6
          }
        end

        it 'Sets winner and returns the finished match' do
          match = finish_match

          expect(match.winner).to eq player2
        end

        it 'Updates rankings of current round for both players and previous opponents' do
          finish_match

          expect(ranking21.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 4, sets_difference: 1, games_difference: -5, relevant: true)
          expect(ranking22.reload).to have_attributes(
              points: 3, toss_points: 3, handicap: 0, sets_difference: 0, games_difference: 11, relevant: true)
          expect(ranking_r2_of_p2_opponent_from_r1.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 2, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Does not update other rankings' do
          finish_match

          expect(ranking11.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4, relevant: false
          )
          expect(ranking12.reload).to have_attributes(
            points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false
          )
          expect(ranking_r1_of_p1_opponent_from_r1.reload).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true
          )
          expect(ranking_r1_of_p2_opponent_from_r1.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false
          )
          expect(ranking_r2_of_p1_opponent_from_r1.reload).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true
          )
        end

        it 'Sets score for the match' do
          match = finish_match

          expect(match.set1_player1_score).to eq 1
          expect(match.set1_player2_score).to eq 6
          expect(match.set2_player1_score).to eq 2
          expect(match.set2_player2_score).to eq 6
          expect(match.set3_player1_score).to be_nil
          expect(match.set3_player2_score).to be_nil
        end

        it 'Sets match finished and published' do
          match = finish_match

          expect(match.finished?).to be true
          expect(match.published?).to be true
        end
      end

      context 'And incorrect score' do
        let(:score) do
          {
            set1_player1: 6,
            set1_player2: 1,
            set2_player1: 5,
            set2_player2: 7
          }
        end

        it 'Returns nil' do
          expect(finish_match).to be_nil
        end

        it 'Does not set score for the match' do
          finish_match
          match.reload

          expect(match.set1_player1_score).to be_nil
          expect(match.set1_player2_score).to be_nil
          expect(match.set2_player1_score).to be_nil
          expect(match.set2_player2_score).to be_nil
          expect(match.set3_player1_score).to be_nil
          expect(match.set3_player2_score).to be_nil
        end

        it 'Does not update rankings of players' do
          finish_match

          expect(ranking11.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4)
          expect(ranking12).to have_attributes(
            points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2)
          expect(ranking21).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 3, games_difference: 4)
          expect(ranking22).to have_attributes(
            points: 2, toss_points: 3, handicap: 0, sets_difference: -2, games_difference: 2)
          expect(ranking_r1_of_p1_opponent_from_r1).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
          expect(ranking_r2_of_p1_opponent_from_r1).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
          expect(ranking_r1_of_p2_opponent_from_r1).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
          expect(ranking_r2_of_p2_opponent_from_r1).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Does not set match finished nor published' do
          finish_match
          match.reload

          expect(match.finished?).to be false
          expect(match.published?).to be false
        end
      end
    end

    context 'With 1 set match' do
      context 'And correct score' do
        let(:score) do
          {
            set1_player1: 6,
            set1_player2: 7
          }
        end

        it 'Sets winner and returns the finished match' do
          match = finish_match

          expect(match.winner).to eq player2
        end

        it 'Sets score for the match' do
          match = finish_match

          expect(match.set1_player1_score).to eq 6
          expect(match.set1_player2_score).to eq 7
          expect(match.set2_player1_score).to be_nil
          expect(match.set2_player2_score).to be_nil
          expect(match.set3_player1_score).to be_nil
          expect(match.set3_player2_score).to be_nil
        end

        it 'Updates rankings of current round for both players and previous opponents' do
          finish_match

          expect(ranking21.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 4, sets_difference: 2, games_difference: 3, relevant: true)
          expect(ranking22.reload).to have_attributes(
              points: 3, toss_points: 3, handicap: 0, sets_difference: -1, games_difference: 3, relevant: true)
          expect(ranking_r2_of_p2_opponent_from_r1.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 2, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Does not update other rankings' do
          finish_match

          expect(ranking11.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4, relevant: false
          )
          expect(ranking12.reload).to have_attributes(
            points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false
          )
          expect(ranking_r1_of_p1_opponent_from_r1.reload).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true
          )
          expect(ranking_r1_of_p2_opponent_from_r1.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false
          )
          expect(ranking_r2_of_p1_opponent_from_r1.reload).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true
          )
        end

        it 'Sets match finished and published' do
          match = finish_match

          expect(match.finished?).to be true
          expect(match.published?).to be true
        end
      end

      context 'With incorrect score' do
        let(:score) do
          {
            set1_player1: 6,
            set1_player2: 6
          }
        end

        it 'Returns nil' do
          expect(finish_match).to be_nil
        end

        it 'Does not set score for the match' do
          finish_match
          match.reload

          expect(match.set1_player1_score).to be_nil
          expect(match.set1_player2_score).to be_nil
          expect(match.set2_player1_score).to be_nil
          expect(match.set2_player2_score).to be_nil
          expect(match.set3_player1_score).to be_nil
          expect(match.set3_player2_score).to be_nil
        end

        it 'Does not update rankings of players' do
          finish_match

          expect(ranking11.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4)
          expect(ranking12).to have_attributes(
            points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2)
          expect(ranking21).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 3, games_difference: 4)
          expect(ranking22).to have_attributes(
            points: 2, toss_points: 3, handicap: 0, sets_difference: -2, games_difference: 2)
          expect(ranking_r1_of_p1_opponent_from_r1).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
          expect(ranking_r2_of_p1_opponent_from_r1).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
          expect(ranking_r1_of_p2_opponent_from_r1).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
          expect(ranking_r2_of_p2_opponent_from_r1).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Does not set match finished nor published' do
          finish_match
          match.reload

          expect(match.finished?).to be false
          expect(match.published?).to be false
        end

        it 'Does not updates attributes' do
          finish_match

          expect(match.reload.note).to eq 'Original note'
        end
      end

      context 'Special case when there is next round with rankings already existing' do
        let!(:round3) { create(:round, season: season) }
        let!(:ranking31) { create(:ranking, round: round3, player: player1, points: ranking21.points, toss_points: ranking21.toss_points, handicap: ranking21.handicap, sets_difference: ranking21.sets_difference, games_difference: ranking21.games_difference) }
        let!(:ranking32) { create(:ranking, round: round3, player: player2, points: ranking22.points, toss_points: ranking22.toss_points, handicap: ranking22.handicap, sets_difference: ranking22.sets_difference, games_difference: ranking22.games_difference) }
        let!(:ranking_r3_of_p2_opponent_from_r1) { create(:ranking, round: round3, player: opponent_r1_p2, points: ranking_r2_of_p2_opponent_from_r1.points, toss_points: ranking_r2_of_p2_opponent_from_r1.toss_points, handicap: ranking_r2_of_p2_opponent_from_r1.handicap, sets_difference: ranking_r2_of_p2_opponent_from_r1.sets_difference, games_difference: ranking_r2_of_p2_opponent_from_r1.games_difference, relevant: ranking_r2_of_p2_opponent_from_r1.relevant) }

        let(:score) do
          {
            set1_player1: 6,
            set1_player2: 7
          }
        end

        it 'Sets winner and returns the finished match' do
          match = finish_match

          expect(match.winner).to eq player2
        end

        it 'Sets score for the match' do
          match = finish_match

          expect(match.set1_player1_score).to eq 6
          expect(match.set1_player2_score).to eq 7
          expect(match.set2_player1_score).to be_nil
          expect(match.set2_player2_score).to be_nil
          expect(match.set3_player1_score).to be_nil
          expect(match.set3_player2_score).to be_nil
        end

        it 'Updates rankings of current round for both players' do
          finish_match

          expect(ranking21.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 4, sets_difference: 2, games_difference: 3, relevant: true)
          expect(ranking22.reload).to have_attributes(
              points: 3, toss_points: 3, handicap: 0, sets_difference: -1, games_difference: 3, relevant: true)
          expect(ranking_r2_of_p2_opponent_from_r1.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 2, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Updates rankings of the next round' do
          finish_match

          expect(ranking31.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 4, sets_difference: 2, games_difference: 3, relevant: true)
          expect(ranking32.reload).to have_attributes(
              points: 3, toss_points: 3, handicap: 0, sets_difference: -1, games_difference: 3, relevant: true)
          expect(ranking_r3_of_p2_opponent_from_r1.reload).to have_attributes(
              points: 0, toss_points: 0, handicap: 2, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Does not update other rankings' do
          finish_match

          expect(ranking11.reload).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4)
          expect(ranking12).to have_attributes(
            points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2)
          expect(ranking_r1_of_p1_opponent_from_r1).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
          expect(ranking_r2_of_p1_opponent_from_r1).to have_attributes(
            points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
          expect(ranking_r1_of_p2_opponent_from_r1).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
          expect(ranking_r2_of_p2_opponent_from_r1).to have_attributes(
            points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
        end

        it 'Sets match finished and published' do
          match = finish_match

          expect(match.finished?).to be true
          expect(match.published?).to be true
        end
      end
    end
  end

  context 'With retirement during the match' do
    subject(:finish_match) do
      described_class.call(
        match,
        score,
        attributes: { retired_player_id: retired_player_id, note: 'Changed note' }
      ).result
    end

    let!(:round3) { create(:round, season: season) }
    let!(:ranking31) { create(:ranking, round: round3, player: player1, points: ranking21.points, toss_points: ranking21.toss_points, handicap: ranking21.handicap, sets_difference: ranking21.sets_difference, games_difference: ranking21.games_difference) }
    let!(:ranking32) { create(:ranking, round: round3, player: player2, points: ranking22.points, toss_points: ranking22.toss_points, handicap: ranking22.handicap, sets_difference: ranking22.sets_difference, games_difference: ranking22.games_difference) }
    let!(:ranking_r3_of_p2_opponent_from_r1) { create(:ranking, round: round3, player: opponent_r1_p2, points: ranking_r2_of_p2_opponent_from_r1.points, toss_points: ranking_r2_of_p2_opponent_from_r1.toss_points, handicap: ranking_r2_of_p2_opponent_from_r1.handicap, sets_difference: ranking_r2_of_p2_opponent_from_r1.sets_difference, games_difference: ranking_r2_of_p2_opponent_from_r1.games_difference, relevant: ranking_r2_of_p2_opponent_from_r1.relevant) }
    let(:retired_player_id) { player1.id }
    let(:score) do
      {
        set1_player1: 6,
        set1_player2: 3,
        set2_player1: 4,
        set2_player2: 2
      }
    end

    it 'Sets winner, retired_player and returns the finished match' do
      match = finish_match

      expect(match.retired_player).to eq player1
      expect(match.winner).to eq player2
    end

    it 'Sets score for the match' do
      match = finish_match

      expect(match.set1_player1_score).to eq 6
      expect(match.set1_player2_score).to eq 3
      expect(match.set2_player1_score).to eq 4
      expect(match.set2_player2_score).to eq 2
    end

    it 'Updates rankings including handicap of the player retired' do
      finish_match

      expect(ranking21.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 4, sets_difference: 2, games_difference: 9, relevant: true)
      expect(ranking22.reload).to have_attributes(
          points: 3, toss_points: 3, handicap: 0, sets_difference: -1, games_difference: -3, relevant: true)
      expect(ranking31.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 4, sets_difference: 2, games_difference: 9, relevant: true)
      expect(ranking32.reload).to have_attributes(
          points: 3, toss_points: 3, handicap: 0, sets_difference: -1, games_difference: -3, relevant: true)
      expect(ranking_r2_of_p2_opponent_from_r1.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 2, sets_difference: 1, games_difference: 5, relevant: false)
      expect(ranking_r3_of_p2_opponent_from_r1.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 2, sets_difference: 1, games_difference: 5, relevant: false)
    end

    it 'Does not update other rankings' do
      finish_match

      expect(ranking11.reload).to have_attributes(
        points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4)
      expect(ranking12).to have_attributes(
        points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2)
      expect(ranking_r1_of_p1_opponent_from_r1).to have_attributes(
        points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
      expect(ranking_r2_of_p1_opponent_from_r1).to have_attributes(
        points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
      expect(ranking_r1_of_p2_opponent_from_r1).to have_attributes(
        points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
    end

    it 'Sets match finished and published' do
      match = finish_match

      expect(match.finished?).to be true
      expect(match.published?).to be true
    end

    it 'Updates attributes' do
      match = finish_match

      expect(match.note).to eq 'Changed note'
    end
  end

  context 'With retirement with no games played' do
    subject(:finish_match) do
      described_class.call(
        match,
        score,
        attributes: { retired_player_id: retired_player_id, note: 'Changed note' }
      ).result
    end

    let!(:round3) { create(:round, season: season) }
    let!(:ranking21) { create(:ranking, round: round2, player: player1, points: 1, toss_points: 1, handicap: 1, sets_difference: 3, games_difference: 4) }
    let!(:ranking22) { create(:ranking, round: round2, player: player2, points: 2, toss_points: 2, handicap: 1, sets_difference: -2, games_difference: 2) }
    let!(:ranking31) { create(:ranking, round: round3, player: player1, points: ranking21.points, toss_points: ranking21.toss_points, handicap: ranking21.handicap, sets_difference: ranking21.sets_difference, games_difference: ranking21.games_difference) }
    let!(:ranking32) { create(:ranking, round: round3, player: player2, points: ranking22.points, toss_points: ranking22.toss_points, handicap: ranking22.handicap, sets_difference: ranking22.sets_difference, games_difference: ranking22.games_difference) }
    let(:retired_player_id) { player2.id }
    let(:score) do
      {}
    end

    it 'Sets winner, looser, retired_player and returns the finished match' do
      match = finish_match

      expect(match.winner).to eq player1
      expect(match.retired_player).to eq player2
      expect(match.looser).to eq player2
    end

    it 'Does not set score for the match' do
      match = finish_match

      expect(match.set1_player1_score).to be_nil
      expect(match.set1_player2_score).to be_nil
      expect(match.set2_player1_score).to be_nil
      expect(match.set2_player2_score).to be_nil
      expect(match.set3_player1_score).to be_nil
      expect(match.set3_player2_score).to be_nil
    end

    it 'Updates rankings of players and winner opponents' do
      finish_match

      expect(ranking21.reload).to have_attributes(
          points: 2, toss_points: 2, handicap: 3, sets_difference: 5, games_difference: 4, relevant: true)
      expect(ranking22.reload).to have_attributes(
          points: 2, toss_points: 2, handicap: 3, sets_difference: -4, games_difference: 2, relevant: false)
      expect(ranking31.reload).to have_attributes(
          points: 2, toss_points: 2, handicap: 3, sets_difference: 5, games_difference: 4, relevant: true)
      expect(ranking32.reload).to have_attributes(
          points: 2, toss_points: 2, handicap: 3, sets_difference: -4, games_difference: 2, relevant: false)
      expect(ranking_r2_of_p1_opponent_from_r1.reload).to have_attributes(
          points: 1, toss_points: 1, handicap: 3, sets_difference: 1, games_difference: 5, relevant: true)

    end

    it 'Does not update other rankings' do
      finish_match

      expect(ranking11.reload).to have_attributes(
          points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 4)
      expect(ranking12).to have_attributes(
          points: 2, toss_points: 2, handicap: 0, sets_difference: -1, games_difference: 2)
      expect(ranking_r1_of_p1_opponent_from_r1).to have_attributes(
          points: 1, toss_points: 1, handicap: 2, sets_difference: 1, games_difference: 5, relevant: true)
      expect(ranking_r1_of_p2_opponent_from_r1).to have_attributes(
          points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
      expect(ranking_r2_of_p2_opponent_from_r1).to have_attributes(
          points: 0, toss_points: 0, handicap: 1, sets_difference: 1, games_difference: 5, relevant: false)
    end

    it 'Sets match finished and published' do
      match = finish_match

      expect(match.finished?).to be true
      expect(match.published?).to be true
    end

    it 'Updates attributes' do
      match = finish_match

      expect(match.note).to eq 'Changed note'
    end
  end
end
