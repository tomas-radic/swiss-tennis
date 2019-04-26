require 'rails_helper'

describe PlayersWithoutMatch do
  subject(:players_without_match) { described_class.call(round: round) }

  let!(:round) { create(:round) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:player3) { create(:player) }
  let!(:player4) { create(:player) }
  let!(:player5) { create(:player) }
  let!(:player6) { create(:player) }
  let!(:player7) { create(:player, :dummy) }
  let!(:match1) { create(:match, round: round, players: [player1, player2], player1: player1, player2: player2) }
  let!(:match2) { create(:match, round: round, players: [player3, player4], player1: player3, player2: player4) }

  it 'Returns players having no match in given round excluding dummy players' do
    players = players_without_match
    expect(players.size).to eq 2
    expect(players).to include(player5, player6)
  end
end
