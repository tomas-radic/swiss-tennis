require 'rails_helper'

RSpec.describe "rounds/index", type: :view do
  before(:each) do
    assign(:rounds, [
      create(:round),
      create(:round)
    ])
  end

  it "renders a list of rounds" do
    render
    assert_select "tr>th", :text => "Position".to_s, :count => 2
  end
end
