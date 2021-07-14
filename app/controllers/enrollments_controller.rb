class EnrollmentsController < ApplicationController

  def index
    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
    @enrollments = selected_season.enrollments
                       .joins(player: :category)
                       .where(players: { dummy: false })
                       .order('enrollments.created_at desc')
                       .order('categories.name')
                       .order('players.last_name')
                       .includes(player: :category)
  end

end
