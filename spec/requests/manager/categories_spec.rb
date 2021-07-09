require 'rails_helper'
require 'requests/requests_spec_helper'

Dir["./spec/requests/manager/shared_examples/*.rb"].sort.each { |f| require f }

include RequestsSpecHelper

RSpec.describe "Categories", type: :request do

  let(:model) { Category }
  let!(:user) { create(:user, password: 'password') }
  let!(:record) { create(:category) }

  let(:valid_params) do
    { category: { name: "Category" } }
  end

  let(:invalid_params) do
    { category: { name: "" } }
  end


  describe "GET /manager/categories" do
    subject { get manager_categories_path }

    it_behaves_like "manager_request_index"
  end


  describe "GET /manager/categories/new" do
    subject { get new_manager_category_path }

    it_behaves_like "manager_request_new"
  end


  describe "POST /manager/categories" do
    subject { post manager_categories_path, params: params }

    it_behaves_like "manager_request_create"
  end


  describe "GET /manager/categories/:id/edit" do
    subject { get edit_manager_category_path(record) }

    it_behaves_like "manager_request_edit"
  end


  describe "PUT /manager/categories/:id" do
    subject { put manager_category_path(record), params: params }

    it_behaves_like "manager_request_update"
  end


  describe "DELETE /manager/categories/:id" do
    subject { delete manager_category_path(record) }

    let(:redirect_path) { manager_categories_path }

    it_behaves_like "manager_request_destroy"
  end
end
