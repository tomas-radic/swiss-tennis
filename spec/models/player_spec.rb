require 'rails_helper'

describe Player, type: :model do
  let!(:category) { create(:category) }

  describe "Validations" do
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


  describe "Instance methods" do

    describe "opponents_in" do
      subject { player.opponents_in current_season }

      let!(:player) { create(:player) }
      let!(:current_season) { create(:season, name: "current") }
      let!(:previous_season) { create(:season, name: "previous") }

      context "When player has matches in given season" do
        let!(:opponent_cs1) { create(:player, first_name: "ocs1") }
        let!(:cs_match1) { create(:match, :finished, round: create(:round, season: current_season),
                                  player1: player, player2: opponent_cs1, players: [player, opponent_cs1]) }

        let!(:opponent_cs2) { create(:player, first_name: "ocs2") }
        let!(:cs_match2) { create(:match, round: create(:round, season: current_season),
                                  player1: opponent_cs2, player2: player, players: [opponent_cs2, player]) }

        let!(:opponent_ps1) { create(:player, first_name: "ops1") }
        let!(:ps_match1) { create(:match, round: create(:round, season: previous_season),
                                  player1: player, player2: opponent_ps1, players: [player, opponent_ps1]) }

        it "Returns player opponents in given season" do
          result = subject

          expect(result).to be_an(ActiveRecord::Relation)
          expect(result.size).to eq(2)
          expect(result).to include(opponent_cs1, opponent_cs2)
        end
      end

      context "When player has no matches in given season" do
        it "Returns none" do
          expect(subject).to be_empty
        end
      end
    end
  end



end
