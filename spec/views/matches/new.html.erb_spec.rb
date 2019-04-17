require 'rails_helper'

RSpec.describe "matches/new", type: :view do
  before(:each) do
    assign(:match, Match.new(
      :player1 => nil,
      :player2 => nil,
      :winner => nil,
      :round => nil,
      :type => "",
      :published => false,
      :note => "MyString"
    ))
  end

  it "renders new match form" do
    render

    assert_select "form[action=?][method=?]", matches_path, "post" do

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
