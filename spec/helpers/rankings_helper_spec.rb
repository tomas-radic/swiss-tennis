require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the RankingsHelper. For example:
#
# describe RankingsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe RankingsHelper, type: :helper do

  describe "rankings_table_row_css_class" do
    subject(:method_result) { rankings_table_row_css_class(ranking) }

    context "With round match finished and new point level" do
      let(:ranking) do
        { round_match_finished: true, new_point_level: true }
      end

      it "Returns correct css classes" do
        expect(method_result).to eq("bg-green border-top-thick")
      end
    end

    context "With round match finished only" do
      let(:ranking) do
        { round_match_finished: true }
      end

      it "Returns correct css classes" do
        expect(method_result).to eq("bg-green")
      end
    end

    context "With new point level" do
      let(:ranking) do
        { round_match_finished: false, new_point_level: true }
      end

      it "Returns correct css classes" do
        expect(method_result).to eq("border-top-thick")
      end
    end

    context "With ranking having no special properties" do
      let(:ranking) do
        { round_match_finished: false }
      end

      it "Returns correct css classes" do
        expect(method_result).to eq("")
      end
    end
  end
end
