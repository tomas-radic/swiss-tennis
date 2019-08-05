require 'rails_helper'

describe MostRecentArticlesQuery do
  subject(:query) { described_class.call(season: season) }

  let!(:season) { create(:season) }
  let!(:user) { create(:user) }
  let!(:article1) { create(:article, updated_at: Article::RECENT_PERIOD.ago - 1.day, season: season, user: user) }
  let!(:article2) { create(:article, updated_at: Article::RECENT_PERIOD.ago + 1.day, season: season, user: user) }
  let!(:article3) { create(:article, updated_at: Article::RECENT_PERIOD.ago + 2.days, last_date_interesting: Date.yesterday, season: season, user: user) }
  let!(:article4) { create(:article, updated_at: Article::RECENT_PERIOD.ago + 3.days, last_date_interesting: Date.today, season: season, user: user) }
  let!(:article5) { create(:article, updated_at: Article::RECENT_PERIOD.ago + 4.days, season: season, user: user) }
  let!(:article6) { create(:article, :draft, updated_at: Article::RECENT_PERIOD.ago + 4.days, season: season, user: user) }

  let!(:another_season) { create(:season) }
  let!(:another_article) { create(:article, updated_at: Article::RECENT_PERIOD.ago + 3.days, season: another_season, user: user) }

  it 'Returns most recent articles from given season' do
    articles = query

    expect(articles.count).to eq 3
    expect(articles[0]).to eq article5
    expect(articles[1]).to eq article4
    expect(articles[2]).to eq article2
  end
end
