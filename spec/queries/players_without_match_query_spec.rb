require 'rails_helper'

describe PlayersWithoutMatchQuery do
  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:player1) { create(:player, first_name: 'Player', last_name: '1') }
  let!(:player2) { create(:player, first_name: 'Player', last_name: '2') }
  let!(:player3) { create(:player, first_name: 'Player', last_name: '3') }
  let!(:player4) { create(:player, first_name: 'Player', last_name: '4') }
  let!(:player5) { create(:player, first_name: 'Player', last_name: '5') }
  let!(:player6) { create(:player, first_name: 'Player', last_name: '6') }
  let!(:player7) { create(:player, :dummy, first_name: 'Player', last_name: '7') }
  let!(:player8) { create(:player, :inactive, first_name: 'Player', last_name: '8') }

  let!(:previous_season) { create(:season) }
  let!(:player9) { create(:player, first_name: 'Player', last_name: '9') }

  before do
    season.players += [player1, player2, player3, player4, player5, player6, player8]
    previous_season.players += [player1, player6, player9]
  end

  context 'Without any existing matches' do
    subject(:players_without_match) { described_class.call(round: round) }

    it 'Returns all players enrolled to the season' do
      players = players_without_match

      expect(players.size).to eq 6
      expect(players).to include(player1, player2, player3, player4, player5, player6)
    end
  end

  context 'With existing matches' do
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
end
