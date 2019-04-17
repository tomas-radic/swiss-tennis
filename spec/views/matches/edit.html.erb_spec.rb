require 'rails_helper'

RSpec.describe "matches/edit", type: :view do
  before(:each) do
    @match = assign(:match, Match.create!(
      :player1 => nil,
      :player2 => nil,
      :winner => nil,
      :round => nil,
      :type => "",
      :published => false,
      :note => "MyString"
    ))
  end

  it "renders the edit match form" do
    render

    assert_select "form[action=?][method=?]", match_path(@match), "post" do

      assert_select "input[name=?]", "match[player1_id]"

      assert_select "input[name=?]", "match[player2_id]"

      assert_select "input[name=?]", "match[winner_id]"

      assert_select "input[name=?]", "match[round_id]"

      assert_select "input[name=?]", "match[type]"

      assert_select "input[name=?]", "match[published]"

      assert_select "input[name=?]", "match[note]"
    end
  end
end
