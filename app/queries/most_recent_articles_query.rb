class MostRecentArticlesQuery < Patterns::Query
  queries Article

  private

  def query
    season.articles.published.sorted
        .where('last_date_interesting >= ? or (last_date_interesting is null and updated_at >= ?)',
               Date.today, Article::RECENT_PERIOD.ago)
  end

  def season
    options.fetch(:season)
  end
end
