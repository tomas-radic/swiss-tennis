require 'rails_helper'

RSpec.describe "enrollments/index.html.erb", type: :view do
  let!(:season) { create(:season) }
  let!(:playerA) { create(:player, seasons: [season], consent_given: true, first_name: "Roger", last_name: "Federer") }
  let!(:playerB) { create(:player, seasons: [season], consent_given: false, first_name: "Rafael", last_name: "Nadal") }
  let!(:playerC) { create(:player, seasons: [season], consent_given: true, first_name: "Grigor", last_name: "Dimitrov") }

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

    expect(rendered).to match(/Roger Federer/)
    expect(rendered).to match(/Rafael N\*\*a\*/)
    expect(rendered).to match(/Grigor Dimitrov/)
  end
end
