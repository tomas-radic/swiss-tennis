require "rails_helper"

RSpec.describe Manager::CategoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/manager/categories").to route_to("manager/categories#index")
    end

    it "routes to #new" do
      expect(:get => "/manager/categories/new").to route_to("manager/categories#new")
    end

    it "routes to #show" do
      expect(:get => "/manager/categories/1").to route_to("manager/categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/manager/categories/1/edit").to route_to("manager/categories#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/manager/categories").to route_to("manager/categories#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/manager/categories/1").to route_to("manager/categories#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/manager/categories/1").to route_to("manager/categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/manager/categories/1").to route_to("manager/categories#destroy", :id => "1")
    end
  end
end
