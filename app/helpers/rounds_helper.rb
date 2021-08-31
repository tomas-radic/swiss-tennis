module RoundsHelper

  def round_element(round, user)
    return nil unless round.present?

    if user.present?
      link_to round.full_label, round_path(round), class: 'btn btn-success'
    else
      round.full_label
    end
  end


  private


  def last_days?(round)
    return false unless round.period_ends.present?

    (round.period_ends - Date.today).to_i <= 7
  end

end
