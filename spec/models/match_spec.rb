require "rails_helper"

RSpec.describe Match, type: :model do
  describe "Validations" do
    context "With valid attributes" do
      let(:match) do
        Match.new(player1: create(:player), player2: create(:player),
                  round: create(:round), finished_at: nil,
                  set1_player1_score: 6, set1_player2_score: 4,
                  set2_player1_score: 6, set2_player2_score: 2,
                  set3_player1_score: nil, set3_player2_score: nil)
      end

      it "Is valid" do
        expect(match).to be_valid
      end
    end

    context "With invalid score" do
      let(:match) do
        Match.new(player1: create(:player), player2: create(:player),
                  round: create(:round), finished_at: nil,
                  set1_player1_score: 6, set1_player2_score: 4,
                  set2_player1_score: 2, set2_player2_score: 6,
                  set3_player1_score: 10, set3_player2_score: 5)
      end

      it "Is not valid" do
        expect(match).not_to be_valid
      end
    end
  end
  
  describe "Scopes" do
    describe "default" do
      let!(:empty_match) { create(:match) }
      let!(:note_match) { create(:match, note: "A note here") }
      let!(:date_match1) { create(:match, play_date: Date.today) }
      let!(:date_match2) { create(:match, play_date: Date.tomorrow) }
      let!(:finished_match) { create(:match, :finished) }

      it "Sorts matches" do
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
