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

  def match_players_enrolled?(match)
    player1_enrollment = Enrollment.active.find_by(player: match.player1, season: match.round.season)
    player2_enrollment = Enrollment.active.find_by(player: match.player2, season: match.round.season)
    return false unless player1_enrollment.present?
    return false unless player2_enrollment.present?
    return false unless match.player1.rounds.include?(match.round)
    return false unless match.player2.rounds.include?(match.round)

    true
  end
end
