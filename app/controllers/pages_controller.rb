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
end
