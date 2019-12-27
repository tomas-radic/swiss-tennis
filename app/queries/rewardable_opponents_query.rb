class RewardableOpponentsQuery < Patterns::Query
  queries Player

  private

  def query
    relation.joins(matches: [round: :season]).merge(Match.finished)
        .where('matches.player1_id = ? or matches.player2_id = ?', player.id, player.id) # only players that have common finished match with given player
        .where.not(players: { id: player.id })          # but exclude the given player itself
        .where('(matches.set1_player1_score is not null and matches.set1_player2_score is not null) or (matches.retired_player_id = ?)', player.id)  # only players from matches that have at least started or retired by given player, not them
        .where(seasons: { id: round.season_id })        # only opponents of given round's season
        .where('rounds.position < ?', round.position)   # only those the given player faced before given round
  end

  def player
    options.fetch(:player)
  end

  def round
    options.fetch(:round)
  end
end
