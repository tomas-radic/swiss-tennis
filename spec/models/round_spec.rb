require 'rails_helper'

RSpec.describe Round, type: :model do
  describe "Instance methods" do

    describe "#full_label" do
      subject(:method_result) { round.full_label }

      context "Round with label filled in" do
        let!(:round) { create(:round, label: "Finals") }

        it "Returns round label" do
          expect(method_result).to eq("Finals")
        end
      end

      context "Round with blank label" do
        let!(:round) { create(:round, label: "") }

        it "Returns round with its position" do
          expect(method_result).to eq("Kolo 1")
        end
      end
    end
  end
end
