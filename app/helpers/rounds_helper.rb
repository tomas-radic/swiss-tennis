module RoundsHelper
  def round_element(round, user)
    return nil unless round.present?

    if user.present?
      link_to round.full_label, round_path(round), class: 'btn btn-success'
    else
      round.full_label
    end
  end
end
