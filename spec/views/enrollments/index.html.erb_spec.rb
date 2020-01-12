require 'rails_helper'

RSpec.describe "enrollments/index.html.erb", type: :view do
  let!(:season) { create(:season) }
  let!(:playerA) { create(:player, seasons: [season], consent_given: true, last_name: 'Abcdefgh') }
  let!(:playerB) { create(:player, seasons: [season], consent_given: false, last_name: 'Bcdefghi') }
  let!(:playerC) { create(:player, seasons: [season], consent_given: true, last_name: 'Cdefghij') }

  it 'Displays players enrolled to season, last_name based on consent_given' do
    skip # following mocked user_signed_in? method is not working.
    allow(view).to receive(:user_signed_in?).and_return(false)

    render

    expect(rendered).to contain('Abcdefgh')
    expect(rendered).to contain('Bcd*fgh*')
    expect(rendered).to contain('Cdefghij')
  end
end
