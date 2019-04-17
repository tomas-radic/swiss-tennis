require 'rails_helper'

RSpec.describe "seasons/index", type: :view do
  before(:each) do
    assign(:seasons, [
      Season.create!(
        :name => "Name"
      ),
      Season.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of seasons" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
