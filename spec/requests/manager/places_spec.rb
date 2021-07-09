require 'rails_helper'
require 'requests/requests_spec_helper'

Dir["./spec/requests/manager/shared_examples/*.rb"].sort.each { |f| require f }

include RequestsSpecHelper

RSpec.describe "Places", type: :request do

  let(:model) { Place }
  let!(:user) { create(:user, password: 'password') }
  let!(:record) { create(:place) }

  let(:valid_params) do
    { place: { name: "Name" } }
  end

  let(:invalid_params) do
    { place: { name: "" } }
  end


  describe "GET /manager/places" do
    subject { get manager_places_path }

    it_behaves_like "manager_request_index"
  end


  describe "GET /manager/places/new" do
    subject { get new_manager_place_path }

    it_behaves_like "manager_request_new"
  end


  describe "POST /manager/places" do
    subject { post manager_places_path, params: params }

    it_behaves_like "manager_request_create"
  end


  describe "GET /manager/places/:id/edit" do
    subject { get edit_manager_place_path(record) }

    it_behaves_like "manager_request_edit"
  end


  describe "PUT /manager/places/:id" do
    subject { put manager_place_path(record), params: params }

    it_behaves_like "manager_request_update"
  end


  describe "DELETE /manager/places/:id" do
    subject { delete manager_place_path(record) }

    let(:redirect_path) { manager_places_path }

    it_behaves_like "manager_request_destroy"
  end
end
