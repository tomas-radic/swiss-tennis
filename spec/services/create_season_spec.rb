require 'rails_helper'

describe CreateSeason do
  subject(:service) { described_class.call(season_name).result }

  let(:season_name) { 'A year' }

  before do
    Category.create!(name: 'Sample category')
  end

  context 'When dummy player is not existing' do
    it 'Creates new season with given name, also creates a dummy player and enrolls to season' do
      service
      new_season = Season.find_by(name: season_name)
      dummy_player = Player.find_by(dummy: true, first_name: 'Večný', last_name: 'Looser')

      expect(new_season).not_to be_nil
      expect(dummy_player).not_to be_nil
      expect(Enrollment.find_by(season: new_season, player: dummy_player)).not_to be_nil
    end
  end

  context 'When dummy player already exists' do
    let!(:dummy_player) { create(:player, :dummy, first_name: 'Večný', last_name: 'Looser') }

    it 'Creates new season and enrolls existing dummy player to it' do
      service
      new_season = Season.find_by(name: season_name)
      dummy_players = Player.where(dummy: true)

      expect(dummy_players.count).to eq(1)
      expect(new_season).not_to be_nil
      expect(Enrollment.find_by(season: new_season, player: dummy_players.first)).not_to be_nil
    end
  end
end
