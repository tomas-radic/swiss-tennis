class DeleteTossPointsFromRankings < ActiveRecord::Migration[5.2]
  def change
    remove_column :rankings, :toss_points, :integer
  end
end
