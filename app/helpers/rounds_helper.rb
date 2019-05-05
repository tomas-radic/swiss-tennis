module RoundsHelper
  def round_element(round, user)
    return nil unless round.present?

    if user.present?
      link_to round.full_label, round_path(round), class: 'btn btn-success'
    else
      round.full_label
    end
  end

  def round_range_info(round)
    return nil if round.period_begins.nil? && round.period_ends.nil?

    text = "Kolo #{round.position} sa hrá"
    text += " od #{I18n.localize(round.period_begins, format: :date_month)}" if round.period_begins.present?
    text += " do #{I18n.localize(round.period_ends, format: :date_month)}" if round.period_ends.present?
    text += '.'

    result_html = "<p><i><small>#{text}"
    if pending_matches?(round) && last_days?(round)
      result_html += " <b><span class=\"text-danger\">Prosíme hráčov aby odohrali a nahlásili výsledok svojho zápasu do termínu #{I18n.localize(round.period_ends, format: :date_month)}.</span></b>"
    end
    result_html += "</small></i></p>"
    result_html.html_safe
  end

  private

  def pending_matches?(round)
    round.matches.published.pending.any?
  end

  def last_days?(round)
    return false unless round.period_ends.present?

    (round.period_ends - Date.today).to_i <= 7
  end
end
