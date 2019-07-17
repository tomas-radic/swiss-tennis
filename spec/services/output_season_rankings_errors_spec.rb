require 'rails_helper'

describe OutputSeasonRankingsErrors do
  subject(:service) { described_class.call(season) }

  let!(:season) { create(:season) }

  it 'Runs SeasonRankings calculation' # do
  #   expect(SeasonRankings).to receive(:result_for).with({ season: season })
  #
  #   service
  # end
end
