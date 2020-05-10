require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe "#formatted_phone" do
    subject(:method_result) { helper.formatted_phone(phone) }

    context "With phone number given" do
      let(:phone) { "0123456789" }

      it "Formats given phone number" do
        expect(method_result).to eq("0123 456 789")
      end
    end

    context "With blank phone number" do
      let(:phone) { '' }

      it "Returns blank phone number" do
        expect(method_result).to eq('')
      end
    end
  end
end
