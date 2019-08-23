require 'rails_helper'
require 'requests/authentication_helpers'

include AuthenticationHelpers

RSpec.describe "Articles", type: :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:article) { create(:article, season: season, user: user) }

  describe "GET /articles" do
    subject(:get_articles) { get articles_path }

    it "Renders index template and responds with success" do
      get_articles

      expect(response).to render_template(:index)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /article/:id" do
    subject(:get_article) { get article_path(article) }

    context 'With published article' do
      it "Renders show template and responds with success" do
        get_article
        expect(response).to render_template(:show)
        expect(response).to have_http_status(200)
      end
    end

    context 'With draft article' do
      let!(:article) { create(:article, :draft, user: user, season: season) }

      before(:each) do
        article.update(published: false)
      end

      it 'Raises error' do
        expect { get_article }.to raise_error Pundit::NotAuthorizedError
      end

      context 'With signed in user' do
        before(:each) do
          login(user, 'password')
        end

        it "Renders show template and responds with success" do
          get_article
          expect(response).to render_template(:show)
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe "GET /articles/new" do
    subject(:get_articles_new) { get new_article_path }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "returns a success response" do
        get_articles_new
        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_articles_new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /articles" do
    subject(:post_articles) { post articles_path, params: params }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      context "With valid params" do
        let(:params) do
          {
            article: {
              title: 'Article about something',
              content: 'Content about something'
            }
          }
        end

        it "Creates new article" do
          expect { post_articles }.to change(Article, :count).by(1)
        end

        it 'Sets current user to the created article' do
          post_articles

          expect(Article.sorted.first.user).to eq user
        end

        it "Redirects to the list of articles" do
          post_articles

          expect(response).to redirect_to articles_path
        end
      end

      context "With invalid params" do
        let(:params) do
          { article: { title: '', content: 'Content of the article' } }
        end

        it "Does not create new article and renders new template" do
          expect{ post_articles }.not_to change(Article, :count)
          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'When logged out' do
      let(:params) do
        {
          article: {
            title: 'Article title',
            content: 'Content of the article'
          }
        }
      end

      it 'Redirects to login' do
        post_articles
        expect(response).to redirect_to login_path
      end

      it 'Does not create new article' do
        expect { post_articles }.not_to change(Article, :count)
      end
    end
  end

  describe "GET /article/:id/edit" do
    subject(:get_article_edit) { get edit_article_path(article) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "returns a success response" do
        get_article_edit
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(200)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        get_article_edit
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "PUT /articles/:id" do
    subject(:put_articles) { put article_path(article), params: params }

    let(:params) do
      {
        article: {
          title: 'Article title',
          content: 'Content of the article',
          last_date_interesting: Date.tomorrow.to_s,
          published: false
        }
      }
    end

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "Updates article attributes" do
        put_articles
        article.reload

        expect(article.title).to eq('Article title')
        expect(article.content).to eq('Content of the article')
        expect(article.last_date_interesting).to eq(Date.tomorrow)
        expect(article.published).to be(false)
      end

      it "Redirects to the article" do
        put_articles
        expect(response).to redirect_to article_path(article)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        put_articles

        expect(response).to redirect_to login_path
      end

      it 'Does not update the article' do
        put_articles

        expect(article.title).not_to eq('Article title')
        expect(article.published).to be(true)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject(:delete_articles) { delete article_path(article) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "Destroys the requested article" do
        expect { delete_articles }.to change(Article, :count).by(-1)
      end

      it "Redirects to the list of all articles" do
        delete_articles

        expect(response).to redirect_to(articles_path)
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        delete_articles

        expect(response).to redirect_to login_path
      end

      it 'Does not destroy the article' do
        expect { delete_articles }.not_to change(Article, :count)
      end
    end
  end



  describe "GET /articles/:id/pin" do
    subject(:pin_article) { get pin_article_path(article) }

    let!(:article) { create(:article, :draft, user: user, season: season, updated_at: 2.days.ago) }

    context 'When logged in' do
      before(:each) do
        login(user, 'password')
      end

      it "Sets updated_at attribute of requested article" do
        pin_article

        expect(article.reload.updated_at).to be > Date.today.beginning_of_day
      end

      it "Sets article published" do
        pin_article

        expect(article.reload.published?).to be true
      end

      it "Redirects back to pinned article" do
        pin_article

        expect(response).to redirect_to(article_path(article))
      end
    end

    context 'When logged out' do
      it 'Redirects to login' do
        pin_article

        expect(response).to redirect_to login_path
      end

      it 'Does not set updated_at attribute of requested article' do
        pin_article

        expect(article.reload.updated_at).not_to be > Date.today.beginning_of_day
      end

      it 'Does not publish the article' do
        pin_article

        expect(article.reload.published?).to be false
      end
    end
  end
end
