class MostRecentArticlesQuery < Patterns::Query
  queries Article

  private

  def query
    season.articles.published.sorted
        .where('updated_at >= ?', Article::RECENT_PERIOD.ago)
        .where('last_date_interesting is null or last_date_interesting >= ?', Date.today)
  end

  def season
    options.fetch(:season)
  end
end
