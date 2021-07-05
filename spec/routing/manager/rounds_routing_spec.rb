require "rails_helper"

RSpec.describe Manager::RoundsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/manager/rounds").to route_to("manager/rounds#index")
    end

    it "routes to #new" do
      expect(:get => "/manager/rounds/new").to route_to("manager/rounds#new")
    end

    it "routes to #show" do
      expect(:get => "/manager/rounds/1").to route_to("manager/rounds#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/manager/rounds/1/edit").to route_to("manager/rounds#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/manager/rounds").to route_to("manager/rounds#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/manager/rounds/1").to route_to("manager/rounds#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/manager/rounds/1").to route_to("manager/rounds#update", :id => "1")
    end
  end
end
