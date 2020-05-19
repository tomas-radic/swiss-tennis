require 'rails_helper'
require 'features/features_spec_helper'

include FeaturesSpecHelper

RSpec.feature "Match create", :type => :feature do

  let!(:user) { create(:user, email: "manager@here.com", password: "Password1") }
  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:player1) { create(:player, seasons: [season], rounds: [round]) }
  let!(:player2) { create(:player, seasons: [season], rounds: [round]) }

  scenario "User creates a new match" do
    features_login(user, "Password1")

    visit new_match_path(round_id: season.rounds.first.id)

    select player1.name, from: "match_player1_id"
    select player2.name, from: "match_player2_id"
    click_button "Potvrdiť"

    expect(page).to have_text("Ok, vybavené.")
  end
end
