module RankingsHelper
  def rankings_table_row_color_class(ranking)
    round_match_played = ranking.player.matches.any? { |m| m.round_id == ranking.round_id && m.finished? }
    round_match_played ? 'bg-green' : ''
  end
end
