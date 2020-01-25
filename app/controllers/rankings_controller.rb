class RankingsController < ApplicationController
  def index
    @rankings = RankingsQuery.call(round: selected_round)
    @last_update_time = @rankings.pluck(:updated_at).max&.in_time_zone
    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
  end
end
