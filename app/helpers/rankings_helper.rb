module RankingsHelper
  def rankings_table_row_css_class(ranking)
    result = ""
    result += "table-bg-green|" if ranking[:all_matches_finished]
    result += "border-top-thick|" if ranking[:new_point_level]

    result.split('|').join(' ')
  end
end
