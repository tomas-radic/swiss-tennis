require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MatchesHelper. For example:
#
# describe MatchesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe MatchesHelper, type: :helper do
  describe "#match_info" do
    subject(:method_result) { match_info(match) }

    context "Match has a date, time, place and a note" do
      let!(:match) { create(:match, play_date: Date.tomorrow, play_time: "16:00", place: create(:place), note: "Some text") }

      it "Returns formatted result" do
        expect(method_result).to eq("#{I18n.l(Date.tomorrow, format: :date_month)} 16:00 Place, Some text")
      end
    end

    context "Match has date and time" do
      let!(:match) { create(:match, play_date: Date.tomorrow, play_time: "16:00", place: nil, note: nil) }

      it "Returns formatted result" do
        expect(method_result).to eq("#{I18n.l(Date.tomorrow, format: :date_month)} 16:00")
      end
    end

    context "Match has date and place" do
      let!(:match) { create(:match, play_date: Date.tomorrow, play_time: nil, place: create(:place), note: nil) }

      it "Returns formatted result" do
        expect(method_result).to eq("#{I18n.l(Date.tomorrow, format: :date_month)} Place")
      end
    end

    context "Match has place and note" do
      let!(:match) { create(:match, play_date: nil, play_time: nil, place: create(:place), note: "Some text") }

      it "Returns formatted result" do
        expect(method_result).to eq("Place, Some text")
      end
    end

    context "Match has note only" do
      let!(:match) { create(:match, play_date: nil, play_time: nil, place: nil, note: "Some text") }

      it "Returns formatted result" do
        expect(method_result).to eq("Some text")
      end
    end
  end
end
