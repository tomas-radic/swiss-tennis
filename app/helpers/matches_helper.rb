module MatchesHelper
  def match_published_pill(match)
    if match.finished?
      '<span class="badge badge-pill badge-success">Zápas je uzavretý.</span>'.html_safe
    elsif match.published?
      '<span class="badge badge-pill badge-danger">Zápas je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Zápas nie je zverejnený.</span>'.html_safe
    end
  end

  def matches_table_row_color_class(match)
    if match.finished_at.nil?
      ''
    elsif match.finished_at > Date.yesterday.midnight
      'bg-yellow'
    else
      'bg-green'
    end
  end

  def match_info(match)
    play_date = I18n.l(match.finished_at&.to_date || match.play_date, format: :date_month) if match.finished_at || match.play_date
    result = [play_date, match.play_time, match.place&.name].reject(&:blank?).join(' ')

    unless match.note.blank?
      result += ", " unless result.blank?
      result += match.note
    end

    result
  end

  def delayed_matches_announcement(delayed_matches)
    count = delayed_matches.count

    if count > 4
      "... plus #{count} neodohratých zápasov z predchádzajúcich kol"
    elsif count > 1
      "... plus #{count} neodohraté zápasy z predchádzajúcich kol"
    elsif count == 1
      "... plus #{count} neodohratý zápas z predchádzajúcich kol"
    end
  end
end
