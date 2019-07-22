class SelectedSeason < Patterns::Calculation
  pattr_initialize [:season_id]

  private

  def result
    selected_season
  end

  def selected_season
    if given_season_id?
      Season.find(season_id)
    else
      Season.default.first
    end
  end

  def given_season_id?
    season_id.present?
  end
end
