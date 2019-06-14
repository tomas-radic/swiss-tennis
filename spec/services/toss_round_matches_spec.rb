require 'rails_helper'

describe TossRoundMatches do
  context 'Without mandatory rankings' do
    subject(:service) { described_class.call(round, player_ids) }

    let!(:round) { create(:round) }
    let!(:previous_round) { create(:round) }
    let!(:r_0p_1) { create(:ranking, round: round, toss_points: 0) }
    let!(:r_1p_1) { create(:ranking, round: round, toss_points: 1) }
    let!(:r_1p_2) { create(:ranking, round: round, toss_points: 1) }
    let!(:r_1p_3) { create(:ranking, round: round, toss_points: 1) }
    let!(:r_2p_1) { create(:ranking, round: round, toss_points: 2) }
    let!(:r_2p_2) { create(:ranking, round: round, toss_points: 2) }
    let!(:r_2p_3) { create(:ranking, round: round, toss_points: 2) }
    let!(:r_2p_4) { create(:ranking, round: round, toss_points: 2) }
    let!(:r_3p_1) { create(:ranking, round: round, toss_points: 3) }
    let!(:r_4p_1) { create(:ranking, round: round, toss_points: 4) }
    let!(:r_4p_2) { create(:ranking, round: round, toss_points: 4) }
    let!(:r_5p_1) { create(:ranking, round: round, toss_points: 5) }
    let!(:r_5p_2) { create(:ranking, round: round, toss_points: 5) }
    let!(:r_5p_3) { create(:ranking, round: round, toss_points: 5) }
    let!(:r_6p_1) { create(:ranking, round: round, toss_points: 6) }
    let!(:r_7p_1) { create(:ranking, round: round, toss_points: 7) }
    let!(:r_9p_pr1) { create(:ranking, round: previous_round, toss_points: 9) }
    let!(:r_9p_pr2) { create(:ranking, round: previous_round, toss_points: 9) }
    let(:player_ids) do
      [
        r_0p_1.player_id, r_1p_1.player_id, r_1p_2.player_id, r_1p_3.player_id, r_2p_1.player_id,
        r_2p_2.player_id, r_2p_3.player_id, r_2p_4.player_id, r_3p_1.player_id, r_4p_1.player_id,
        r_4p_2.player_id, r_5p_1.player_id, r_5p_2.player_id, r_5p_3.player_id, r_6p_1.player_id,
        r_7p_1.player_id, r_9p_pr1.player_id, r_9p_pr2.player_id
      ]
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
  end

  context 'With specified players that are not allowed to have byes' do

  end
end
