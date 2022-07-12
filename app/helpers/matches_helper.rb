module MatchesHelper

  RECENT = (Time.now.in_time_zone - 1.day).beginning_of_day


  def match_published_pill(match)
    if match.finished?
      '<span class="badge badge-pill badge-success">Zápas je uzavretý.</span>'.html_safe
    elsif match.published?
      '<span class="badge badge-pill badge-danger">Zápas je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Zápas nie je zverejnený.</span>'.html_safe
    end
  end


  def match_info(match)
    play_date = match.finished_at || match.play_date
    play_date = I18n.l(play_date, format: :date_month) if play_date

    result = []
    result << play_date if play_date
    result << match.play_time if match.finished_at.blank? && play_date && match.play_time
    result << match.place.name if match.place && play_date
    result = result.join(' ')

    if match.note.present?
      result += ", " if result.present?
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
