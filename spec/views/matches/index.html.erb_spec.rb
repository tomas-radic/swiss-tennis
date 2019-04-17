require 'rails_helper'

RSpec.describe "matches/index", type: :view do
  before(:each) do
    assign(:matches, [
      Match.create!(
        :player1 => nil,
        :player2 => nil,
        :winner => nil,
        :round => nil,
        :type => "Type",
        :published => false,
        :note => "Note"
      ),
      Match.create!(
        :player1 => nil,
        :player2 => nil,
        :winner => nil,
        :round => nil,
        :type => "Type",
        :published => false,
        :note => "Note"
      )
    ])
  end

  it "renders a list of matches" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Note".to_s, :count => 2
  end
end
