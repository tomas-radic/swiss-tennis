require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the PlayersHelper. For example:
#
# describe PlayersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

describe PlayersHelper, type: :helper do
  describe 'player_name_by_consent' do
    subject(:method_result) { player_name_by_consent(player, user) }

    context 'Without known user' do
      let(:user) { nil }

      context 'With consent given' do
        let!(:player) { create(:player, first_name: 'Roger', last_name: 'Federer', consent_given: true) }

        it 'Returns readable name of the player' do
          expect(method_result).to eq('Roger Federer')
        end
      end

      context 'Without consent given' do
        let!(:player) { create(:player, first_name: 'Roger', last_name: 'Federer', consent_given: false) }

        it 'Returns anonymized name of the player' do
          expect(method_result).to eq('Roger F***r**')
        end
      end

      context 'With dummy player' do
        let!(:player) { create(:player, :dummy, first_name: 'Alltime', last_name: 'Looser', consent_given: false) }

        it 'Returns readable name of the player' do
          expect(method_result).to eq('Alltime Looser')
        end
      end
    end

    context 'With known user' do
      let!(:user) { create(:user) }

      context 'With consent given' do
        let!(:player) { create(:player, first_name: 'Roger', last_name: 'Federer', consent_given: true) }

        it 'Returns readable name of the player' do
          expect(method_result).to eq('Roger Federer')
        end
      end

      context 'Without consent given' do
        let!(:player) { create(:player, first_name: 'Roger', last_name: 'Federer', consent_given: false) }

        it 'Returns name of the player with last letter changed to star' do
          expect(method_result).to eq('Roger Federe*')
        end
      end

      context 'With dummy player' do
        let!(:player) { create(:player, :dummy, first_name: 'Alltime', last_name: 'Looser', consent_given: false) }

        it 'Returns readable name of the player' do
          expect(method_result).to eq('Alltime Looser')
        end
      end
    end
  end
end
