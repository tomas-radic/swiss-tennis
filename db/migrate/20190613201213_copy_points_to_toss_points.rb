class CopyPointsToTossPoints < ActiveRecord::Migration[5.2]
  def change
    Ranking.all.each do |ranking|
      ranking.toss_points = ranking.points
      ranking.save!
    end
  end
end
