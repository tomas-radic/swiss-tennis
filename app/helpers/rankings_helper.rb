module RankingsHelper
  def rankings_table_row_css_class(ranking)
    result = ""
    result += "bg-green|" if ranking[:round_match_finished]
    result += "border-top-thick|" if ranking[:new_point_level]

    result.split('|').join(' ')
  end
end
