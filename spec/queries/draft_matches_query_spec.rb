require 'rails_helper'

describe DraftMatchesQuery do
  subject(:draft_matches_query) { described_class.call(round: round) }

  let!(:round) { create(:round) }
  let!(:finished_match) { create(:match, :finished, round: round) }
  let!(:published_match) { create(:match, round: round) }
  let!(:draft_match) { create(:match, :draft, round: round) }

  let!(:another_round_draft_match) { create(:match, :draft) }

  it 'Returns draft matches of given round' do
    matches = draft_matches_query

    expect(matches.count).to eq 1
    expect(matches.ids).to include(draft_match.id)
  end
end
