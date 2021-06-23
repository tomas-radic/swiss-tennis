class RankingsController < ApplicationController

  def index
    if selected_round
      @rankings = SortedRankings.result_for(round: selected_round)
      @matches_to_play = Match.published.pending.not_dummy
                              .joins(:round).where("rounds.position <= ?", selected_round.position)
                              .includes(:players, :round)

      @last_update_time = @rankings.map { |r| r[:updated_at] }.max&.in_time_zone
    else
      @rankings = []
    end

    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
  end
end
