require 'rails_helper'

RSpec.describe "seasons/show", type: :view do
  before(:each) do
    @season = assign(:season, Season.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
