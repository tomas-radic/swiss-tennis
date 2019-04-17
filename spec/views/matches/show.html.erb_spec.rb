require 'rails_helper'

RSpec.describe "matches/show", type: :view do
  before(:each) do
    @match = assign(:match, Match.create!(
      :player1 => nil,
      :player2 => nil,
      :winner => nil,
      :round => nil,
      :type => "Type",
      :published => false,
      :note => "Note"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Note/)
  end
end
