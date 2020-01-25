require 'rails_helper'

describe TossRoundMatches do
  subject(:service) { described_class.call(round, toss_points) }

  let!(:season) { create(:season) }

  context 'With blank rankings (1st round toss)' do
    let!(:round) { create(:round, season: season) }

    let!(:ranking1) { create(:ranking, round: round) }
    let!(:ranking2) { create(:ranking, round: round) }
    let!(:ranking3) { create(:ranking, round: round) }
    let!(:ranking4) { create(:ranking, round: round) }
    let!(:ranking5) { create(:ranking, round: round) }
    let(:toss_points) do
      {
          ranking1.player_id => '0',
          ranking2.player_id => '0',
          ranking3.player_id => '0',
          ranking4.player_id => '0',
          ranking5.player_id => '0'
      }
    end

    before do
      season.players = [ranking1.player, ranking2.player, ranking3.player, ranking4.player, ranking5.player]
    end

    it 'Creates matches combining players randomly' do
      service

      expect(round.reload.matches.count).to eq(2)
    end
  end

  context 'With non-blank rankings' do
    let!(:round) { create(:round, season: season) }
    let!(:previous_round) { create(:round, season: season) }
    let!(:r_0p_1) { create(:ranking, round: round) }
    let!(:r_1p_1) { create(:ranking, round: round) }
    let!(:r_1p_2) { create(:ranking, round: round) }
    let!(:r_1p_3) { create(:ranking, round: round) }
    let!(:r_2p_1) { create(:ranking, round: round) }
    let!(:r_2p_2) { create(:ranking, round: round) }
    let!(:r_2p_3) { create(:ranking, round: round) }
    let!(:r_2p_4) { create(:ranking, round: round) }
    let!(:r_3p_1) { create(:ranking, round: round) }
    let!(:r_4p_1) { create(:ranking, round: round) }
    let!(:r_4p_2) { create(:ranking, round: round) }
    let!(:r_5p_1) { create(:ranking, round: round) }
    let!(:r_5p_2) { create(:ranking, round: round) }
    let!(:r_5p_3) { create(:ranking, round: round) }
    let!(:r_6p_1) { create(:ranking, round: round) }
    let!(:r_7p_1) { create(:ranking, round: round) }
    let!(:r_9p_pr1) { create(:ranking, round: previous_round) }
    let!(:r_9p_pr2) { create(:ranking, round: previous_round) }
    let(:toss_points) do
      {
        r_0p_1.player_id => '0', r_1p_1.player_id => '1', r_1p_2.player_id => '1',
        r_1p_3.player_id => '1', r_2p_1.player_id => '2', r_2p_2.player_id => '2',
        r_2p_3.player_id => '2', r_2p_4.player_id => '2', r_3p_1.player_id => '3',
        r_4p_1.player_id => '4', r_4p_2.player_id => '4', r_5p_1.player_id => '5',
        r_5p_2.player_id => '5', r_5p_3.player_id => '5', r_6p_1.player_id => '6',
        r_7p_1.player_id => '7', r_9p_pr1.player_id => '9', r_9p_pr2.player_id => '9'
      }
    end

    let!(:match) do
      create(
        :match,
        round: round,
        player1: r_6p_1.player,
        player2: r_7p_1.player,
        players: [r_6p_1.player, r_7p_1.player]
      )
    end

    before do
      season.players = [
          r_0p_1.player, r_1p_1.player, r_1p_2.player, r_1p_3.player, r_2p_1.player, r_2p_2.player,
          r_2p_3.player, r_2p_4.player, r_3p_1.player, r_4p_1.player, r_4p_2.player, r_5p_1.player,
          r_5p_2.player, r_5p_3.player, r_6p_1.player, r_7p_1.player, r_9p_pr1.player, r_9p_pr2.player
      ]
    end

    it 'Creates matches for all available players' do
      service

      expect(round.reload.matches.toss.count).to eq 7
      expect(round.reload.matches.count).to eq 8
    end

    it 'Does not combine players with different rankings' do
      service

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_0p_1.player_id, r_2p_1.player_id, r_2p_1.player_id, r_0p_1.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_0p_1.player_id, r_2p_2.player_id, r_2p_2.player_id, r_0p_1.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_0p_1.player_id, r_2p_3.player_id, r_2p_3.player_id, r_0p_1.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_0p_1.player_id, r_2p_4.player_id, r_2p_4.player_id, r_0p_1.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_1p_2.player_id, r_3p_1.player_id, r_3p_1.player_id, r_1p_2.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_3p_1.player_id, r_5p_1.player_id, r_5p_1.player_id, r_3p_1.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_3p_1.player_id, r_5p_2.player_id, r_5p_2.player_id, r_3p_1.player_id
        )
      ).to be_empty

      expect(
        Match.where(
          '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
          r_3p_1.player_id, r_5p_3.player_id, r_5p_3.player_id, r_3p_1.player_id
        )
      ).to be_empty
    end

    it 'Ignores players having rankings in another rounds only' do
      expect(
        Match.where(
          'player1_id in (?) or player2_id in (?)',
          r_9p_pr1.player_id, r_9p_pr2.player_id
        )
      ).to be_empty
    end

    context 'With previously played matches' do
      let!(:played_match1) do
        create(
          :match,
          round: previous_round,
          player1: r_0p_1.player,
          player2: r_1p_1.player,
          players: [r_0p_1.player, r_1p_1.player]
        )
      end

      let!(:played_match2) do
        create(
          :match,
          round: previous_round,
          player1: r_0p_1.player,
          player2: r_1p_2.player,
          players: [r_0p_1.player, r_1p_2.player]
        )
      end

      let!(:played_match3) do
        create(
          :match,
          round: previous_round,
          player1: r_0p_1.player,
          player2: r_1p_3.player,
          players: [r_0p_1.player, r_1p_3.player]
        )
      end

      it 'Does not combine player that have already played against each other' do
        service

        expect(
          Match.where(
            '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
            r_0p_1.player_id, r_1p_1.player_id, r_1p_1.player_id, r_0p_1.player_id
          ).where(round: round)
        ).to be_empty

        expect(
          Match.where(
            '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
            r_0p_1.player_id, r_1p_2.player_id, r_1p_2.player_id, r_0p_1.player_id
          ).where(round: round)
        ).to be_empty

        expect(
          Match.where(
            '(player1_id = ? and player2_id = ?) or (player1_id = ? and player2_id = ?)',
            r_0p_1.player_id, r_1p_3.player_id, r_1p_3.player_id, r_0p_1.player_id
          ).where(round: round)
        ).to be_empty
      end
    end
  end

  context 'With specified players that are not allowed to have byes'
end
