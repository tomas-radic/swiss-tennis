class OutputSeasonRankingsErrors < Patterns::Service
  pattr_initialize :season

  def call
    output_season_rankings_errors
  end

  private

  def output_season_rankings_errors
    puts "Searching for errors in rankings, season #{season.name}..."

    season_rankings.each do |ranking|
      calculated_ranking_hash = calculated_rankings_hashes.find { |r| r[:id] == ranking.id }

      if calculated_ranking_hash.nil?
        puts "Ranking #{ranking.id} should not exist (round #{ranking.round}, player #{ranking.player.name})"
      else
        column_names.each do |column_name|
          if ranking.send(column_name) != calculated_ranking_hash[column_name.to_sym]
            output_error(column_name, ranking, calculated_ranking_hash)
          end
        end
      end
    end

    puts "\nDone.\n"
  end

  def output_error(attribute_name, ranking, ranking_hash)
    puts "\nRound #{ranking.round.full_label}, player #{ranking.player.name}"
    puts "#{attribute_name} is #{ranking.send(attribute_name).to_s}, expected #{ranking_hash[attribute_name.to_sym].to_s}"
  end

  def calculated_rankings_hashes
    @calculated_rankings_hashes ||= RecalculatedRankings.result_for(season: season)
  end

  def season_rankings
    @season_rankings ||= Ranking.joins(:round)
        .where(rounds: { season_id: season.id })
        .includes(:round, :player)
  end

  def column_names
    @column_names ||= Ranking.column_names.select do |column_name|
      %w(points handicap sets_difference games_difference relevant).include?(column_name)
    end
  end
end
