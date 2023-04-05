class PagesController < ApplicationController

  def about
  end


  def season_jumpers
    @season_jumpers = SeasonJumpers.result_for(season: selected_season)
                   .select { |j| j[:jump] > 0 }
  end


  def rules
  end


  def season2023
    @enrollments = Season.find_by(name: "2023")&.enrollments&.active
                     &.joins(:player)&.where("players.dummy is false")
                     &.order('enrollments.updated_at desc')
                     &.includes(player: :category)
  end

end
