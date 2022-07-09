class MatchDecorator < SimpleDelegator
  include PlayersHelper

  def score
    [set1, set2, set3].reject(&:blank?).join("<br>").html_safe
  end

  def set1
    return '' if set1_player1_score.nil? || set1_player2_score.nil?
    @set1 ||= "#{set1_player1_score}:#{set1_player2_score}"
  end

  def set2
    return '' if set2_player1_score.nil? || set2_player2_score.nil?
    @set2 ||= "#{set2_player1_score}:#{set2_player2_score}"
  end

  def set3
    return '' if set3_player1_score.nil? || set3_player2_score.nil?
    @set3 ||= "#{set3_player1_score}:#{set3_player2_score}"
  end

  def label(user = nil)
    [player_name_by_consent(player1, user), player_name_by_consent(player2, user)].join(' vs ')
  end
end
