require 'rails_helper'

describe PublishedMatchesQuery do
  subject(:published_matches_query) { described_class.call(round: round) }

  let!(:round) { create(:round) }
  let!(:finished_match) { create(:match, :finished, round: round) }
  let!(:published_match) { create(:match, round: round) }
  let!(:draft_match) { create(:match, :draft, round: round) }

  let!(:another_round_published_match) { create(:match) }

  it 'Returns published matches of given round' do
    matches = published_matches_query

    expect(matches.count).to eq 2
    expect(matches.ids).to include(finished_match.id, published_match.id)
  end
end
