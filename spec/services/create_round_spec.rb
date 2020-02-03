require 'rails_helper'

describe CreateRound do
  subject(:create_round) { described_class.call(attributes).result }

  let!(:previous_season) { create(:season) }
  let!(:current_season) { create(:season) }
  let!(:player1) { create(:player) }
  let!(:player2) { create(:player) }
  let!(:player3) { create(:player) }
  let!(:player4) { create(:player) }

  # Players 1-4 enrolled to previous season
  let!(:enrollment1p) { create(:enrollment, season: previous_season, player: player1) }
  let!(:enrollment2p) { create(:enrollment, season: previous_season, player: player2) }
  let!(:enrollment3p) { create(:enrollment, season: previous_season, player: player3) }
  let!(:enrollment4p) { create(:enrollment, season: previous_season, player: player4) }

  # Players 1-3 enrolled to current season, player2 has canceled enrollment
  let!(:enrollment1c) { create(:enrollment, season: current_season, player: player1) }
  let!(:enrollment2c) { create(:enrollment, :canceled, season: current_season, player: player2) }
  let!(:enrollment3c) { create(:enrollment, season: current_season, player: player3) }

  # Previous season rounds
  let!(:round1p) { create(:round, season: previous_season) }

  # Current season rounds
  let!(:round1c) { create(:round, season: current_season, position: 1) }
  let!(:round2c) { create(:round, season: current_season, position: 2) }

  # Previous season rankings
  let!(:ranking1p) { create(:ranking, :relevant, round: round1p, player: player1, points: 1, handicap: 1, sets_difference: 1, games_difference: 1) }
  let!(:ranking2p) { create(:ranking, :relevant, round: round1p, player: player2, points: 2, handicap: 2, sets_difference: 2, games_difference: 2) }

  # Current season rankings
  let!(:ranking1c1) { create(:ranking, :relevant, round: round1c, player: player1, points: 3, handicap: 3, sets_difference: 1, games_difference: 3) }
  let!(:ranking1c2) { create(:ranking, :relevant, round: round1c, player: player2, points: 4, handicap: 4, sets_difference: 3, games_difference: 3) }
  let!(:ranking2c1) { create(:ranking, :relevant, round: round2c, player: player1, points: 5, handicap: 5, sets_difference: 2, games_difference: 5) }
  let!(:ranking2c2) { create(:ranking, :relevant, round: round2c, player: player2, points: 6, handicap: 6, sets_difference: 4, games_difference: 6) }

  let(:attributes) do
    {
      season_id: current_season.id,
      label: 'Finals',
      period_begins: Date.today.to_s,
      period_ends: Date.tomorrow.to_s
    }
  end

  it 'Creates new round for given season' do
    round = create_round

    expect(current_season.rounds.count).to eq 3
    expect(round.position).to eq 3
    expect(round.season).to eq current_season
    expect(round.label).to eq 'Finals'
    expect(round.period_begins).to eq Date.today
    expect(round.period_ends).to eq Date.tomorrow
  end

  it 'Creates rankings for created round and all players with active enrollment for the round season' do
    round = create_round

    expect(Ranking.count).to eq 8
    expect(round.rankings.count).to eq 2
    expect(round.rankings.find_by(player: player1)).to have_attributes(
      points: 5, handicap: 5, sets_difference: 2, games_difference: 5, relevant: true
    )
    expect(round.rankings.find_by(player: player3)).to have_attributes(
      points: 0, handicap: 0, sets_difference: 0, games_difference: 0, relevant: false
    )
  end

  it 'Does not create new round for previous season' do
    create_round
    expect(previous_season.rounds.count).to eq 1
  end
end
