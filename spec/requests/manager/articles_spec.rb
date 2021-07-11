require 'rails_helper'
require 'requests/requests_spec_helper'

Dir["./spec/requests/manager/shared_examples/*.rb"].sort.each { |f| require f }

include RequestsSpecHelper

RSpec.describe "Articles", type: :request do

  let(:model) { Article }
  let!(:user) { create(:user, password: 'password') }
  let!(:season) { create(:season) }
  let!(:record) { create(:article, season: season, user: user) }

  let(:valid_params) do
    {
      article: {
        title: 'Article about something',
        content: 'Content about something'
      }
    }
  end

  let(:invalid_params) do
    {
      article: {
        title: '',
        content: 'Content about something'
      }
    }
  end


  describe "GET /manager/articles/new" do
    subject { get new_manager_article_path }

    it_behaves_like "manager_request_new"
  end


  describe "POST /manager/articles" do
    subject { post manager_articles_path, params: params }

    it_behaves_like "manager_request_create"
  end


  describe "GET /manager/articles/:id/edit" do
    subject { get edit_manager_article_path(record) }

    it_behaves_like "manager_request_edit"
  end


  describe "PUT /manager/articles/:id" do
    subject { put manager_article_path(record), params: params }

    it_behaves_like "manager_request_update"
  end


  describe "DELETE /manager/articles/:id" do
    subject { delete manager_article_path(record) }

    let(:redirect_path) { articles_path }

    it_behaves_like "manager_request_destroy"
  end


  describe "GET /manager/articles/:id/pin" do
    subject { get pin_manager_article_path(record) }

    let!(:record) do
      create(:article, :draft, user: user, season: season,
             updated_at: 2.days.ago, last_date_interesting: Date.yesterday)
    end

    context 'When logged in' do
      before(:each) do
        requests_login(user, 'password')
      end

      it "Calls PinArticle service object and redirects to the article" do
        expect(PinArticle).to receive(:call).with(record)

        subject

        expect(response).to redirect_to(article_path record)
      end
    end

    context 'When logged out' do
      it 'Does not call PinArticle and redirects to login' do
        expect(PinArticle).not_to receive(:call)

        subject

        expect(response).to redirect_to login_path
      end
    end
  end
end
