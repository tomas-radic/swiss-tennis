require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the RoundsHelper. For example:
#
# describe RoundsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

RSpec.describe RoundsHelper, type: :helper do
  describe 'round_progress_info' do
    subject(:method) { round_progress_info(round) }

    context 'When there are no dates specified' do
      let!(:round) { create(:round, period_begins: nil, period_ends: nil) }

      it 'Does not raise an error' do
        expect { method }.not_to raise_error
      end
    end
  end
end
