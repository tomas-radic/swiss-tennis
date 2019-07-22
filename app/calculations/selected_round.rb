class SelectedRound < Patterns::Calculation
  pattr_initialize :season, [:round_id]

  private

  def result
    selected_round
  end

  def selected_round
    return @selected_round if @selected_round

    @selected_round = season.rounds.find_by(id: round_id) if round_id_given?
    @selected_round ||= season.rounds.default.joins(:matches).where('matches.published is true').first
    @selected_round ||= season.rounds.default.first

    @selected_round
  end

  def round_id_given?
    round_id.present?
  end
end
