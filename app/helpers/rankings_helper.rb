module RankingsHelper
  def ranking_table_row(ranking, order_number)
    round_match_played = ranking.player.matches.any? { |m| m.round_id == ranking.round_id && m.finished? }
    row_class = round_match_played ? 'bg-green' : ''
    result_html =  "<tr class=\"#{row_class}\">
                      <td>#{order_number}</td>
                      <td>#{link_to(ranking.player.name, player_path(ranking.player), class: 'quiet-link')}</td>
                      <td>#{ranking.points}</td>"

    if user_signed_in?
      result_html += "<td class=\"#{'text-danger' if ranking.toss_points != ranking.points}\">#{ranking.toss_points}</td>"
    end

    result_html += "<td>#{ranking.handicap}</td>"

    if user_signed_in?
      result_html += "<td>#{link_to 'Upraviť', edit_ranking_path(ranking), class: 'btn btn-sm btn-success'}</td>"
    end

    result_html += "</tr>"
    result_html.html_safe
  end
end
