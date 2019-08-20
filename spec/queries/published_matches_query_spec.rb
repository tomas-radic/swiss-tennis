require 'rails_helper'

describe PublishedMatchesQuery do
  subject(:published_matches_query) { described_class.call }

  let!(:season) { create(:season) }
  let!(:round) { create(:round, season: season) }
  let!(:another_round) { create(:round, season: season) }
  let!(:dummy_player) { create(:player, :dummy) }
  let!(:finished_match) { create(:match, :finished, round: round) }
  let!(:published_match) { create(:match, :published, round: round) }
  let!(:published_match_with_dummy_player1) { create(:match, :published, round: round, player1: dummy_player) }
  let!(:published_match_with_dummy_player2) { create(:match, :published, round: round, player2: dummy_player) }
  let!(:draft_match) { create(:match, :draft, round: round) }
  let!(:published_match_from_another_round) { create(:match, :published, round: another_round) }

  it 'Returns published matches where none of the players is a dummy player' do
    matches = published_matches_query

    expect(matches.count).to eq 3
    expect(matches.ids).to include(
      finished_match.id,
      published_match.id,
      published_match_from_another_round.id
    )
  end
end
