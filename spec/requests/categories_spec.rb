require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Categories", type: :request do
  let!(:user) { create(:user, password: 'nbusr123') }
  let!(:category) { create(:category) }

  describe "GET /categories" do
    subject { get categories_path }

    it "Renders index template and responds with success" do
      subject
      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /categories/new" do
    subject { get new_category_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "returns a success response" do
        subject
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "GET /categories/abc/edit" do
    subject { get edit_category_path(category) }

    let!(:category) { create(:category) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "returns a success response" do
        subject
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /categories" do
    subject { post categories_path, params: params }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      context "With valid params" do
        let(:params) do
          { category: { name: 'Category name' } }
        end

        it "Creates a new Category" do
          expect{subject}.to change(Category, :count).by(1)
        end

        it "Redirects to list of categories" do
          subject
          expect(response).to redirect_to categories_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { category: { name: '' } }
        end

        it "Does not create new category and renders new template" do
          expect{subject}.not_to change(Category, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { category: { name: 'Category name' } }
      end

      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end

      it 'Does not create the category' do
        expect{subject}.not_to change(Category, :count)
      end
    end
  end

  describe "PUT /categories/abc" do
    subject { put category_path(category), params: params }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      context "With valid params" do
        let(:params) do
          { category: { name: 'Changed name' } }
        end

        it "Updates the requested category" do
          expect{subject}.not_to change(Category, :count)
          category.reload

          expect(category.name).to eq 'Changed name'
        end

        it "Redirects to list of categories" do
          subject
          expect(response).to redirect_to categories_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { category: { name: '' } }
        end

        it "Does not change the category and renders edit template" do
          subject
          category.reload

          expect(category.name).not_to eq 'Changed name'
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        { category: { name: 'Changed name' } }
      end

      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end

      it 'Does not update the category' do
        subject
        expect(category.name).not_to eq 'Changed name'
      end
    end
  end

  describe "DELETE /categories/abc" do
    subject { delete category_path(category) }

    context 'When logged in' do
      before(:each) do
        login(user, 'nbusr123')
      end

      it "Destroys the requested category" do
        expect{subject}.to change(Category, :count).by(-1)
      end

      it "Redirects to the categories list" do
        subject
        expect(response).to redirect_to(categories_path)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        subject
        expect(response).to redirect_to login_path
      end

      it 'Does not destroy the category' do
        expect{subject}.not_to change(Category, :count)
      end
    end
  end
end
