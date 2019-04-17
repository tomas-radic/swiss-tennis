require 'rails_helper'

RSpec.describe "rounds/edit", type: :view do
  before(:each) do
    @round = assign(:round, create(:round))
  end

  it "renders the edit round form" do
    render

    assert_select "form[action=?][method=?]", round_path(@round), "post" do

      assert_select "input[name=?]", "round[position]"
    end
  end
end
