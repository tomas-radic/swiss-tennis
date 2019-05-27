require 'rails_helper'

describe FinishMatch do
  let!(:season) { create(:season) }
  let!(:round1) { create(:round, season: season) }
  let!(:round2) { create(:round, season: season) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }

  let!(:ranking11) { create(:ranking, round: round1, player: player1, points: 0, handicap: 0, sets_difference: 1, games_difference: 4) }
  let!(:ranking12) { create(:ranking, round: round1, player: player2, points: 1, handicap: 0, sets_difference: -1, games_difference: 2) }
  let!(:ranking21) { create(:ranking, round: round2, player: player1, points: 0, handicap: 0, sets_difference: 3, games_difference: 4) }
  let!(:ranking22) { create(:ranking, round: round2, player: player2, points: 1, handicap: 0, sets_difference: -2, games_difference: 2) }
  # NOTE: before finishing match in round 2, rankings are copies of previous rankings from round 1

  let!(:match) { create(:match, :draft, round: round2, player1: player1, player2: player2) }

  context 'Without retirement' do
    subject(:finish_match) { described_class.call(match, score).result }

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

      it 'Updates rankings of current round for both players' do
        finish_match

        expect(ranking21.reload).to have_attributes(
            points: 1, handicap: 1, sets_difference: 4, games_difference: 7, relevant: true)
        expect(ranking22.reload).to have_attributes(
            points: 1, handicap: 0, sets_difference: -3, games_difference: -1, relevant: true)
      end

      it 'Does not update rankings of previous round' do
        finish_match

        expect(ranking11.reload).to have_attributes(
            points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
        expect(ranking12.reload).to have_attributes(
            points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
      end

      it 'Sets match finished and published' do
        match = finish_match

        expect(match.finished?).to be true
        expect(match.published?).to be true
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

        it 'Updates rankings of current round for both players' do
          finish_match

          expect(ranking21.reload).to have_attributes(
              points: 0, handicap: 1, sets_difference: 1, games_difference: -5, relevant: true)
          expect(ranking22.reload).to have_attributes(
              points: 2, handicap: 0, sets_difference: 0, games_difference: 11, relevant: true)
        end

        it 'Does not update rankings of previous round' do
          finish_match

          expect(ranking11.reload).to have_attributes(
              points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
          expect(ranking12.reload).to have_attributes(
              points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
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
            points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
          expect(ranking12.reload).to have_attributes(
            points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
          expect(ranking21.reload).to have_attributes(
            points: 0, handicap: 0, sets_difference: 3, games_difference: 4, relevant: false)
          expect(ranking22.reload).to have_attributes(
            points: 1, handicap: 0, sets_difference: -2, games_difference: 2, relevant: false)
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

        it 'Updates rankings of current round for both players' do
          finish_match

          expect(ranking21.reload).to have_attributes(
              points: 0, handicap: 1, sets_difference: 2, games_difference: 3, relevant: true)
          expect(ranking22.reload).to have_attributes(
              points: 2, handicap: 0, sets_difference: -1, games_difference: 3, relevant: true)
        end

        it 'Does not update rankings of previous round' do
          finish_match

          expect(ranking11.reload).to have_attributes(
              points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
          expect(ranking12.reload).to have_attributes(
              points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
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
              points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
          expect(ranking12.reload).to have_attributes(
              points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
          expect(ranking21.reload).to have_attributes(
              points: 0, handicap: 0, sets_difference: 3, games_difference: 4, relevant: false)
          expect(ranking22.reload).to have_attributes(
              points: 1, handicap: 0, sets_difference: -2, games_difference: 2, relevant: false)
        end

        it 'Does not set match finished nor published' do
          finish_match
          match.reload

          expect(match.finished?).to be false
          expect(match.published?).to be false
        end
      end

      context 'Special case when there is next round with rankings already existing' do
        let!(:round3) { create(:round, season: season) }
        let!(:ranking31) { create(:ranking, round: round3, player: player1, points: 0, handicap: 0, sets_difference: 3, games_difference: 4) }
        let!(:ranking32) { create(:ranking, round: round3, player: player2, points: 1, handicap: 0, sets_difference: -2, games_difference: 2) }
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
              points: 0, handicap: 1, sets_difference: 2, games_difference: 3, relevant: true)
          expect(ranking22.reload).to have_attributes(
              points: 2, handicap: 0, sets_difference: -1, games_difference: 3, relevant: true)
        end

        it 'Updates rankings of the next round as well' do
          finish_match

          expect(ranking31.reload).to have_attributes(
              points: 0, handicap: 1, sets_difference: 2, games_difference: 3, relevant: true)
          expect(ranking32.reload).to have_attributes(
              points: 2, handicap: 0, sets_difference: -1, games_difference: 3, relevant: true)
        end

        it 'Does not update rankings of previous round' do
          finish_match

          expect(ranking11.reload).to have_attributes(
              points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
          expect(ranking12.reload).to have_attributes(
              points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
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
        retirement: { retired_player_id: retired_player_id }
      ).result
    end

    let!(:round3) { create(:round, season: season) }
    let!(:ranking31) { create(:ranking, round: round3, player: player1, points: ranking21.points, handicap: ranking21.handicap, sets_difference: ranking21.sets_difference, games_difference: ranking21.games_difference) }
    let!(:ranking32) { create(:ranking, round: round3, player: player2, points: ranking22.points, handicap: ranking22.handicap, sets_difference: ranking22.sets_difference, games_difference: ranking22.games_difference) }
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
          points: 0, handicap: 1, sets_difference: 4, games_difference: 9, relevant: true)
      expect(ranking22.reload).to have_attributes(
          points: 2, handicap: 0, sets_difference: -3, games_difference: -3, relevant: true)
      expect(ranking31.reload).to have_attributes(
          points: 0, handicap: 1, sets_difference: 4, games_difference: 9, relevant: true)
      expect(ranking32.reload).to have_attributes(
          points: 2, handicap: 0, sets_difference: -3, games_difference: -3, relevant: true)
    end

    it 'Does not update rankings of previous round' do
      finish_match

      expect(ranking11.reload).to have_attributes(
          points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
      expect(ranking12.reload).to have_attributes(
          points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
    end

    it 'Sets match finished and published' do
      match = finish_match

      expect(match.finished?).to be true
      expect(match.published?).to be true
    end
  end

  context 'With retirement with no games played' do
    subject(:finish_match) do
      described_class.call(
        match,
        score,
        retirement: { retired_player_id: retired_player_id }
      ).result
    end

    let!(:round3) { create(:round, season: season) }
    let!(:ranking21) { create(:ranking, round: round2, player: player1, points: 1, handicap: 1, sets_difference: 3, games_difference: 4) }
    let!(:ranking22) { create(:ranking, round: round2, player: player2, points: 2, handicap: 1, sets_difference: -2, games_difference: 2) }
    let!(:ranking31) { create(:ranking, round: round3, player: player1, points: ranking21.points, handicap: ranking21.handicap, sets_difference: ranking21.sets_difference, games_difference: ranking21.games_difference) }
    let!(:ranking32) { create(:ranking, round: round3, player: player2, points: ranking22.points, handicap: ranking22.handicap, sets_difference: ranking22.sets_difference, games_difference: ranking22.games_difference) }
    let(:retired_player_id) { player1.id }
    let(:score) do
      {}
    end

    it 'Sets winner, retired_player and returns the finished match' do
      match = finish_match

      expect(match.retired_player).to eq player1
      expect(match.winner).to eq player2
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

    it 'Updates only points and handicap for the player who had not retired' do
      finish_match

      expect(ranking21.reload).to have_attributes(
          points: 1, handicap: 1, sets_difference: 3, games_difference: 4, relevant: false)
      expect(ranking22.reload).to have_attributes(
          points: 3, handicap: 2, sets_difference: -2, games_difference: 2, relevant: true)
      expect(ranking31.reload).to have_attributes(
          points: 1, handicap: 1, sets_difference: 3, games_difference: 4, relevant: false)
      expect(ranking32.reload).to have_attributes(
          points: 3, handicap: 2, sets_difference: -2, games_difference: 2, relevant: true)
    end

    it 'Does not update rankings of previous round' do
      finish_match

      expect(ranking11.reload).to have_attributes(
          points: 0, handicap: 0, sets_difference: 1, games_difference: 4, relevant: false)
      expect(ranking12.reload).to have_attributes(
          points: 1, handicap: 0, sets_difference: -1, games_difference: 2, relevant: false)
    end

    it 'Sets match finished and published' do
      match = finish_match

      expect(match.finished?).to be true
      expect(match.published?).to be true
    end
  end
end
