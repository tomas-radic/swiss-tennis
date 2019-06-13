class AddTossPointsToRankings < ActiveRecord::Migration[5.2]
  def change
    add_column :rankings, :toss_points, :integer, null: false, default: 0
  end
end
