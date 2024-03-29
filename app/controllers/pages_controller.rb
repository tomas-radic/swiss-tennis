class PagesController < ApplicationController

  def about; end


  def season_jumpers
    @season_jumpers = SeasonJumpers.result_for(season: selected_season)
                   .select { |j| j[:jump] > 0 }
  end


  def rules; end


  def season2024
    @enrollments = Season.find_by(name: "2024")&.enrollments&.active
                     &.joins(:player)&.where("players.dummy is false")
                     &.order('enrollments.updated_at desc')
                     &.includes(player: :category)
  end

  def reservations; end
end
