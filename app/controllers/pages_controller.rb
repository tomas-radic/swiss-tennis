class PagesController < ApplicationController
  def about
  end

  def season_jumpers
    @season_jumpers = SeasonJumpers.result_for(season: selected_season)
                   .select { |j| j[:jump] > 0 }
  end

  def game_rules
  end

  # def season2020
  # end

  def season2021
    @enrollments = Season.find_by(name: "2021")&.enrollments&.active
                     &.joins(:player)&.where("players.dummy is false")
                     &.order('enrollments.created_at desc')
                     &.includes(player: :category)
  end
end
