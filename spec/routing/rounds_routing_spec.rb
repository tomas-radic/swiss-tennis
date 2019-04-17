require "rails_helper"

RSpec.describe RoundsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/rounds").to route_to("rounds#index")
    end

    it "routes to #new" do
      expect(:get => "/rounds/new").to route_to("rounds#new")
    end

    it "routes to #show" do
      expect(:get => "/rounds/1").to route_to("rounds#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/rounds/1/edit").to route_to("rounds#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/rounds").to route_to("rounds#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/rounds/1").to route_to("rounds#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/rounds/1").to route_to("rounds#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/rounds/1").to route_to("rounds#destroy", :id => "1")
    end
  end
end
