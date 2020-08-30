require 'rails_helper'

describe SeasonJumpers, type: :model do
  subject(:calculation) { described_class.result_for(season: current_season) }

  let!(:current_season) { create(:season) }

  # Players
  let!(:playerA) { create(:player, first_name: 'Player', last_name: 'A') }
  let!(:playerB) { create(:player, first_name: 'Player', last_name: 'B', seasons: [current_season]) }
  let!(:playerC) { create(:player, first_name: 'Player', last_name: 'C', seasons: [current_season]) }
  let!(:playerD) { create(:player, first_name: 'Player', last_name: 'D', seasons: [current_season]) }
  let!(:playerE) { create(:player, first_name: 'Player', last_name: 'E', seasons: [current_season]) }
  let!(:playerF) { create(:player, first_name: 'Player', last_name: 'F', seasons: [current_season]) }

  context "With existing previous season" do
    let!(:previous_season) { create(:season) }

    before do
      # Sort seasons
      previous_season.insert_at 1
      current_season.insert_at 2

      # Enroll players to season
      create(:enrollment, player: playerA, season: previous_season)
      create(:enrollment, player: playerB, season: previous_season)
      create(:enrollment, player: playerC, season: previous_season)
      create(:enrollment, player: playerD, season: previous_season)
      create(:enrollment, player: playerE, season: previous_season)
    end

    context "With existing rounds/rankings in both seasons" do
      let!(:round_c1) { create(:round, season: current_season) }
      let!(:round_c2) { create(:round, season: current_season) }
      let!(:round_c3) { create(:round, season: current_season) }
      let!(:round_p1) { create(:round, season: previous_season) }
      let!(:round_p2) { create(:round, season: previous_season) }

      before do
        # Sort rounds
        round_c1.insert_at 1
        round_c2.insert_at 2
        round_c3.insert_at 3
        round_p1.insert_at 1
        round_p2.insert_at 2

        # Previous season rankings
        create(:ranking, player: playerA, round: round_p1, points: 10)
        create(:ranking, player: playerB, round: round_p1, points: 9)
        create(:ranking, player: playerC, round: round_p1, points: 8)
        create(:ranking, player: playerD, round: round_p1, points: 7)
        create(:ranking, player: playerE, round: round_p1, points: 6)

        create(:ranking, player: playerA, round: round_p2, points: 20)
        create(:ranking, player: playerB, round: round_p2, points: 19)
        create(:ranking, player: playerC, round: round_p2, points: 18)
        create(:ranking, player: playerD, round: round_p2, points: 17)
        create(:ranking, player: playerE, round: round_p2, points: 16)


        # Current season rankings
        create(:ranking, player: playerB, round: round_c1, points: 99)
        create(:ranking, player: playerC, round: round_c1, points: 88)
        create(:ranking, player: playerD, round: round_c1, points: 77)
        create(:ranking, player: playerE, round: round_c1, points: 66)
        create(:ranking, player: playerF, round: round_c1, points: 55)

        create(:ranking, player: playerB, round: round_c2, points: 199)
        create(:ranking, player: playerC, round: round_c2, points: 188)
        create(:ranking, player: playerD, round: round_c2, points: 177)
        create(:ranking, player: playerE, round: round_c2, points: 166)
        create(:ranking, player: playerF, round: round_c2, points: 155)

        create(:ranking, player: playerB, round: round_c3, points: 21)
        create(:ranking, player: playerC, round: round_c3, points: 15)
        create(:ranking, player: playerD, round: round_c3, points: 25)
        create(:ranking, player: playerE, round: round_c3, points: 18)
        create(:ranking, player: playerF, round: round_c3, points: 40)
      end

      it "Returns hash of players enrolled to both seasons sorted by subtracts of positions" do
        result = calculation

        expect(result).to be_an Array
        expect(result.length).to eq(4)
        expect(result[0][:player_name]).to eq("Player D")
        expect(result[1][:player_name]).to eq("Player E")
        expect(result[2][:player_name]).to eq("Player B")
        expect(result[3][:player_name]).to eq("Player C")
      end
    end

    context "With missing round in previous season" do
      let!(:round_c1) { create(:round, season: current_season) }
      let!(:round_c2) { create(:round, season: current_season) }
      let!(:round_c3) { create(:round, season: current_season) }

      before do
        # Sort rounds
        round_c1.insert_at 1
        round_c2.insert_at 2
        round_c3.insert_at 3

        # Current season rankings
        create(:ranking, player: playerB, round: round_c1, points: 99)
        create(:ranking, player: playerC, round: round_c1, points: 88)
        create(:ranking, player: playerD, round: round_c1, points: 77)
        create(:ranking, player: playerE, round: round_c1, points: 66)
        create(:ranking, player: playerF, round: round_c1, points: 55)

        create(:ranking, player: playerB, round: round_c2, points: 199)
        create(:ranking, player: playerC, round: round_c2, points: 188)
        create(:ranking, player: playerD, round: round_c2, points: 177)
        create(:ranking, player: playerE, round: round_c2, points: 166)
        create(:ranking, player: playerF, round: round_c2, points: 155)

        create(:ranking, player: playerB, round: round_c3, points: 21)
        create(:ranking, player: playerC, round: round_c3, points: 15)
        create(:ranking, player: playerD, round: round_c3, points: 25)
        create(:ranking, player: playerE, round: round_c3, points: 18)
        create(:ranking, player: playerF, round: round_c3, points: 40)
      end

      it "Returns empty array" do
        result = calculation
        expect(result).to be_an Array
        expect(result).to be_empty
      end
    end

    context "With missing round in current season" do
      let!(:round_p1) { create(:round, season: previous_season) }
      let!(:round_p2) { create(:round, season: previous_season) }

      before do
        # Sort rounds
        round_p1.insert_at 1
        round_p2.insert_at 2

        # Previous season rankings
        create(:ranking, player: playerA, round: round_p1, points: 10)
        create(:ranking, player: playerB, round: round_p1, points: 9)
        create(:ranking, player: playerC, round: round_p1, points: 8)
        create(:ranking, player: playerD, round: round_p1, points: 7)
        create(:ranking, player: playerE, round: round_p1, points: 6)

        create(:ranking, player: playerA, round: round_p2, points: 20)
        create(:ranking, player: playerB, round: round_p2, points: 19)
        create(:ranking, player: playerC, round: round_p2, points: 18)
        create(:ranking, player: playerD, round: round_p2, points: 17)
        create(:ranking, player: playerE, round: round_p2, points: 16)
      end

      it "Returns empty array" do
        result = calculation
        expect(result).to be_an Array
        expect(result).to be_empty
      end
    end

  end

  context "Without previous season" do
    let!(:round_c1) { create(:round, season: current_season) }
    let!(:round_c2) { create(:round, season: current_season) }
    let!(:round_c3) { create(:round, season: current_season) }

    before do
      # Sort rounds
      round_c1.insert_at 1
      round_c2.insert_at 2
      round_c3.insert_at 3

      # Current season rankings
      create(:ranking, player: playerB, round: round_c1, points: 99)
      create(:ranking, player: playerC, round: round_c1, points: 88)
      create(:ranking, player: playerD, round: round_c1, points: 77)
      create(:ranking, player: playerE, round: round_c1, points: 66)
      create(:ranking, player: playerF, round: round_c1, points: 55)

      create(:ranking, player: playerB, round: round_c2, points: 199)
      create(:ranking, player: playerC, round: round_c2, points: 188)
      create(:ranking, player: playerD, round: round_c2, points: 177)
      create(:ranking, player: playerE, round: round_c2, points: 166)
      create(:ranking, player: playerF, round: round_c2, points: 155)

      create(:ranking, player: playerB, round: round_c3, points: 21)
      create(:ranking, player: playerC, round: round_c3, points: 15)
      create(:ranking, player: playerD, round: round_c3, points: 25)
      create(:ranking, player: playerE, round: round_c3, points: 18)
      create(:ranking, player: playerF, round: round_c3, points: 40)
    end

    it "Returns empty array" do
      result = calculation
      expect(result).to be_an Array
      expect(result).to be_empty
    end
  end

end
