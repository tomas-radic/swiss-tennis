require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'Scopes' do
    describe 'default' do
      let!(:empty_match) { create(:match) }
      let!(:note_match) { create(:match, note: 'A note here') }
      let!(:date_match1) { create(:match, play_date: Date.today) }
      let!(:date_match2) { create(:match, play_date: Date.tomorrow) }
      let!(:finished_match) { create(:match, :finished) }

      it 'Sorts matches' do
        matches = Match.default

        expect(matches[0]).to eq finished_match
        expect(matches[1]).to eq date_match1
        expect(matches[2]).to eq date_match2
        expect(matches[3]).to eq note_match
        expect(matches[4]).to eq empty_match
      end
    end
  end
end
