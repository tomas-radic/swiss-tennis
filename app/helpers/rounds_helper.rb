module RoundsHelper
  def round_element(round, user)
    return nil unless round.present?

    if user.present?
      link_to round.full_label, round_path(round), class: 'btn btn-success'
    else
      round.full_label
    end
  end

  def round_progress_info(round)
    return nil if round.nil?

    published_matches_count = round.matches.published.size
    finished_matches_count = round.matches.finished.size
    missing_matches = (published_matches_count - finished_matches_count) > 0
    highlight = missing_matches && last_days?(round)
    text = "#{finished_matches_count} z #{published_matches_count} zápasov ukončených."
    result_html = "<div class='progress' style='height: 4px;'>
                    <div class='progress-bar #{highlight ? 'bg-danger' : 'bg-success'}' role='progressbar' style='width: #{(finished_matches_count / published_matches_count.to_f) * 100}%;' aria-valuenow='#{finished_matches_count}' aria-valuemin='0' aria-valuemax='#{published_matches_count}'></div>
                  </div>
                  <p>
                    <small><i>#{text}"

    if round.period_begins.present? || round.period_ends.present?
      text = " Kolo #{round.position} sa hrá"
      text += " od #{I18n.localize(round.period_begins, format: :date_month)}" if round.period_begins.present?
      text += " do #{I18n.localize(round.period_ends, format: :date_month)}" if round.period_ends.present?
      text += '.'
      result_html += "#{text}"

      if missing_matches
        result_html += " <b><span class=\"attention-background #{highlight ? 'text-danger' : 'text-success'}\">Prosíme hráčov, aby organizátorovi súťaže nahlásili termín svojho zápasu v tomto kole najneskôr do termínu #{I18n.localize(round.period_ends - 7.days, format: :date_month)}, 20:00.</span></b>"
      end
    end

    result_html += "</i></small></p>"
    result_html.html_safe
  end

  private

  def last_days?(round)
    return false unless round.period_ends.present?

    (round.period_ends - Date.today).to_i <= 7
  end
end
