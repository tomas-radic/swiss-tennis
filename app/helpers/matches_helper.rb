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
      result_html += "<strong>#{link_to(match.player1.name, player_path(match.player1), class: 'quiet-link')}</strong>"
    elsif match.player1 == match.retired_player
      result_html += "<span class=\"text-secondary\">#{link_to(match.player1.name, player_path(match.player1), class: 'quiet-link')}</span>"
    else
      result_html += link_to(match.player1.name, player_path(match.player1), class: 'quiet-link')
    end

    result_html += " (#{match.player1.rankings.find { |r| r[:round_id] == match.round.id }&.points.to_i}b)"
    result_html += "<br><small><i>#{link_to match.player1.phone, "tel:#{match.player1.phone}"}</i></small></td><td>"

    if match.player2_id == match.winner_id
      result_html += "<strong>#{link_to(match.player2.name, player_path(match.player2), class: 'quiet-link')}</strong>"
    elsif match.player2 == match.retired_player
      result_html += "<span class=\"text-secondary\">#{link_to(match.player2.name, player_path(match.player2), class: 'quiet-link')}</span>"
    else
      result_html += link_to(match.player2.name, player_path(match.player2), class: 'quiet-link')
    end

    result_html += " (#{match.player2.rankings.find { |r| r[:round_id] == match.round.id }&.points.to_i}b)"
    result_html += "<br><small><i>#{link_to match.player2.phone, "tel:#{match.player2.phone}"}</i></small></td>"
    result_html +=  "<td>#{match.note}</td>"
    result_html += "<td>#{MatchDecorator.new(match).score}</td>"
    result_html += "<td>#{link_to 'Detail', match_path(match), class: 'btn btn-sm btn-success'}</td></tr>"
    result_html.html_safe
  end
end
