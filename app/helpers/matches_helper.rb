module MatchesHelper
  def published_pill(match)
    if match.published?
      '<span class="badge badge-pill badge-danger">Zápas je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Zápas nie je zverejnený.</span>'.html_safe
    end
  end

  def match_table_row(match)
    color_class = if match.finished_at.present?
      if match.finished_at > Date.yesterday.midnight
        'bg-yellow'
      else
        'bg-green'
      end
    else
      ''
    end

    result_html = "<tr class=\"#{color_class}\"><td>"

    if match.player1_id == match.winner_id
      result_html += "<strong>#{match.player1.name}</strong>"
    else
      result_html += match.player1.name
    end

    result_html += "<br><small><i>#{link_to match.player1.phone, "tel:#{match.player1.phone}"}</i></small></td><td>"

    if match.player2_id == match.winner_id
      result_html += "<strong>#{match.player2.name}</strong>"
    else
      result_html += match.player2.name
    end

    result_html += "<br><small><i>#{link_to match.player2.phone, "tel:#{match.player2.phone}"}</i></small></td>"
    result_html +=  "<td>#{match.note}</td>"
    result_html += "<td>#{MatchDecorator.new(match).score}</td>"
    result_html += "<td>#{link_to 'Detail', match_path(match), class: 'btn btn-sm btn-success'}</td></tr>"
    result_html.html_safe
  end
end
