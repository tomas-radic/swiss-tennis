require 'rails_helper'
require 'requests/requests_spec_helper'

include RequestsSpecHelper

RSpec.describe "Articles", type: :request do

  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:record) { create(:article, season: season, user: user) }


  describe "GET /articles" do
    subject { get articles_path }

    it "Renders index template and responds with success" do
      subject

      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end


  describe "GET /article/:id" do
    subject { get article_path(record) }

    context 'With published article' do
      it "Renders show template and responds with success" do
        subject

        expect(response).to render_template(:show)
        expect(response).to have_http_status(200)
      end
    end

    context 'With draft article' do
      let!(:record) { create(:article, :draft, user: user, season: season) }

      it 'Raises error' do
        expect { subject }.to raise_error Pundit::NotAuthorizedError
      end

      context 'With signed in user' do
        before(:each) do
          requests_login(user, 'password')
        end

        it "Renders show template and responds with success" do
          subject

          expect(response).to render_template(:show)
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
