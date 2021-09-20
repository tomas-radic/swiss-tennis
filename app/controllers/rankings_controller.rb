class RankingsController < ApplicationController

  def index
    HttpRequest.where("updated_at < ?", 4.weeks.ago).destroy_all
    log_http_request! unless user_signed_in?

    @nominations_to_finals = []

    if selected_round
      @rankings = SortedRankings.result_for(round: selected_round)

      Category.sorted.where("nr_finalists > ?", 0).each do |category|
        finalists = @rankings.select { |r| r[:player_enrollment_active] && r[:player].category == category }.first(category.nr_finalists).map { |r| r[:player] }

        @nominations_to_finals << {
          category: category,
          finalists: finalists
        }
      end

      @matches_to_play = policy_scope(Match).published.pending
                              .joins(:round)
                              .where("rounds.position <= ?", selected_round.position)
                              .where("rounds.season_id = ?", selected_season.id)
                              .includes(:players, :round)

      @last_update_time = @rankings.map { |r| r[:updated_at] }.max&.in_time_zone

      # Counts
      @nr_round_matches = selected_season.matches.published.not_dummy
                                         .joins(:round)
                                         .where(rounds: { position: selected_round.position })
                                         .count
      @nr_finished_matches = selected_season.matches.published.not_dummy.finished
                                            .joins(:round)
                                            .where(rounds: { position: selected_round.position })
                                            .count
    else
      @rankings = []
    end


    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
  end


  private

  def selected_round
    if params["round_id"].present?
      round = selected_season.rounds.find params["round_id"]
    else
      round = selected_season.rounds.default.regular.joins(:matches).where('matches.published is true').first
      round ||= selected_season.rounds.default.regular.first
      round ||= selected_season.rounds.default.first
    end

    round
  end
end
