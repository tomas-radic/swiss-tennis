require 'rails_helper'

RSpec.describe "enrollments/index.html.erb", type: :view do
  let!(:season) { create(:season) }
  let!(:playerA) { create(:player, seasons: [season], consent_given: true, last_name: 'Abcdefgh') }
  let!(:playerB) { create(:player, seasons: [season], consent_given: false, last_name: 'Bcdefghi') }
  let!(:playerC) { create(:player, seasons: [season], consent_given: true, last_name: 'Cdefghij') }

  it 'Displays players enrolled to season, last_name based on consent_given' do
    assign(:enrollments, Enrollment.all)

    def view.user_signed_in?
      false
    end

    def view.current_user
      nil
    end

    def view.selected_season
      Season.first
    end

    render

    expect(rendered).to match('Abcdefgh')
    expect(rendered).to match('B***f***')
    expect(rendered).to match('Cdefghij')
  end
end
