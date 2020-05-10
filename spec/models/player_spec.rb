require 'rails_helper'

describe Player, type: :model do
  let!(:category) { create(:category) }

  context "With valid attributes" do
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer", category_id: category.id)
    end

    it "Is valid" do
      expect(player).to be_valid
    end
  end

  context "With 10 digit phone" do
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer",
                 phone: "0123456789", category_id: category.id)
    end

    it "Is valid" do
      expect(player).to be_valid
    end
  end

  context "With 10 digit phone number + whitespaces" do
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer",
                 phone: "0123 456 789", category_id: category.id)
    end

    it "Is valid" do
      expect(player).to be_valid
    end
  end

  context "With non-numeric phone number" do
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer",
                 phone: "0X23456789", category_id: category.id)
    end

    it "Is not valid" do
      expect(player).not_to be_valid
    end
  end

  context "With other than 10 digit phone number" do
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer",
                 phone: "00123456789", category_id: category.id)
    end

    it "Is not valid" do
      expect(player).not_to be_valid
    end
  end

  context "With phone number already existing" do
    let!(:existing_player) { create(:player, phone: "0123456789") }
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer",
                 phone: "0123456789", category_id: category.id)
    end

    it "Is not valid" do
      expect(player).not_to be_valid
    end
  end

  context "With email already existing" do
    let!(:existing_player) { create(:player, email: "roger@federer.com") }
    let(:player) do
      Player.new(first_name: "Roger", last_name: "Federer",
                 email: "roger@federer.com", category_id: category.id)
    end

    it "Is not valid" do
      expect(player).not_to be_valid
    end
  end

  context "Without first_name" do
    let(:player) do
      Player.new(last_name: "Federer", category_id: category.id)
    end

    it "Is not valid" do
      expect(player).not_to be_valid
    end
  end

  context "Without last_name" do
    let(:player) do
      Player.new(first_name: "Roger", category_id: category.id)
    end

    it "Is not valid" do
      expect(player).not_to be_valid
    end
  end



end
