class RankingsController < ApplicationController

  def index
    if selected_round
      @rankings = SortedRankings.result_for(round: selected_round)
      @last_update_time = @rankings.pluck(:updated_at).max&.in_time_zone
    else
      @rankings = []
    end

    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
  end
end
