module MatchesHelper

  RECENT = Time.zone.yesterday.midnight.freeze


  def match_published_pill(match)
    if match.finished?
      '<span class="badge badge-pill badge-success">Zápas je uzavretý.</span>'.html_safe
    elsif match.published?
      '<span class="badge badge-pill badge-danger">Zápas je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Zápas nie je zverejnený.</span>'.html_safe
    end
  end


  def match_css_class(match)
    if match.finished_at.nil?
      match.play_date.nil? ? '' : 'table-bg-smoke'
    elsif match.finished_at > RECENT
      'table-bg-yellow'
    else
      'table-bg-green'
    end
  end


  def match_player_css_class(match, player)
    if match.finished_at.nil?
      ''

    elsif player == match.winner
      if match.finished_at > RECENT
        'font-weight-bold table-bg-darken-yellow'
      else
        'font-weight-bold table-bg-darken-green'
      end

    elsif player == match.retired_player
      'dark-gray'
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


  def unplanned_matches_info(matches_count)
    word = if matches_count > 4
      "#{matches_count} zápasov nemá dátum."
    elsif matches_count > 1
      "#{matches_count} zápasy nemajú dátum."
    elsif matches_count == 1
      "#{matches_count} zápas nemá dátum."
    end
  end
end
