require 'rails_helper'

describe PlayersWithoutMatchQuery do
  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:next_round) { create(:round, season: season) }
  let!(:player1) { create(:player, first_name: 'Player', last_name: '1', rounds: [next_round, round]) }
  let!(:player2) { create(:player, first_name: 'Player', last_name: '2', rounds: [next_round, round]) }
  let!(:player3) { create(:player, first_name: 'Player', last_name: '3', rounds: [next_round, round]) }
  let!(:player4) { create(:player, first_name: 'Player', last_name: '4', rounds: [next_round, round]) }
  let!(:player5) { create(:player, first_name: 'Player', last_name: '5', rounds: [next_round, round]) }
  let!(:player6) { create(:player, first_name: 'Player', last_name: '6', rounds: [next_round, round]) }
  let!(:player7) { create(:player, :dummy, first_name: 'Player', last_name: '7') }
  let!(:player8) { create(:player, :inactive, first_name: 'Player', last_name: '8', rounds: [next_round, round]) }
  let!(:player9) { create(:player, first_name: 'Player', last_name: '9', rounds: [next_round]) }

  let!(:previous_season) { create(:season) }
  let!(:previous_season_round) { create(:round, season: previous_season) }
  let!(:player10) { create(:player, first_name: 'Player', last_name: '9', rounds: [previous_season_round]) }

  before do
    season.players += [player1, player2, player3, player4, player5, player6, player8]
    previous_season.players += [player1, player6, player10]
  end

  context 'Without any existing matches' do
    subject(:players_without_match) { described_class.call(round: round) }

    it 'Returns all players enrolled to the season' do
      players = players_without_match

      expect(players.size).to eq 6
      expect(players).to include(player1, player2, player3, player4, player5, player6)
    end
  end

  context 'With canceled enrollments' do
    subject(:players_without_match) { described_class.call(round: round) }

    before do
      player2.enrollments.find_by(season: season).update!(canceled: true)
      player4.enrollments.find_by(season: season).update!(canceled: true)
    end

    it 'Returns only not canceled enrollments' do
      players = players_without_match

      expect(players.size).to eq 4
      expect(players).to include(player1, player3, player5, player6)
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
