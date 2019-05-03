require 'rails_helper'

describe PlayersWithoutMatch do
  let!(:round) { create(:round) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:player3) { create(:player) }
  let!(:player4) { create(:player) }
  let!(:player5) { create(:player) }
  let!(:player6) { create(:player) }
  let!(:player7) { create(:player, :dummy) }
  let!(:player8) { create(:player, :inactive) }
  let!(:match1) { create(:match, round: round, player1: player1, player2: player2) }
  let!(:match2) { create(:match, round: round, player1: player3, player2: player4) }

  context 'Not to include dummy' do
    subject(:players_without_match) { described_class.call(round: round) }

    it 'Returns active players having no match in given round excluding dummy' do
      players = players_without_match
      expect(players.size).to eq 2
      expect(players).to include(player5, player6)
    end
  end

  context 'To include dummy' do
    subject(:players_without_match) { described_class.call(round: round, include_dummy: true) }

    it 'Returns active players having no match in given round including dummy players' do
      players = players_without_match
      expect(players.size).to eq 3
      expect(players).to include(player5, player6, player7)
    end
  end
end
