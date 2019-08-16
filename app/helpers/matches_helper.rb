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
end
