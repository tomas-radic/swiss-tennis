class RankingsController < ApplicationController

  def index
    if selected_round
      @rankings = SortedRankings.result_for(round: selected_round)
      mark_point_levels!


      @last_update_time = @rankings.pluck(:updated_at).max&.in_time_zone
    else
      @rankings = []
    end

    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
  end

  private

  def mark_point_levels!
    last_point_level_ranking = nil

    @rankings.map do |ranking|
      if last_point_level_ranking && ranking[:points] != last_point_level_ranking
        ranking[:new_point_level] = true
      end

      last_point_level_ranking = ranking[:points]
    end
  end
end
