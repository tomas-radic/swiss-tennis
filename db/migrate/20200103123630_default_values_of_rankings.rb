class DefaultValuesOfRankings < ActiveRecord::Migration[5.2]
  def change
    change_column :rankings, :points, :integer, null: false, default: 0
    change_column :rankings, :toss_points, :integer, null: false, default: 0
    change_column :rankings, :handicap, :integer, null: false, default: 0
    change_column :rankings, :sets_difference, :integer, null: false, default: 0
    change_column :rankings, :games_difference, :integer, null: false, default: 0
    change_column :rankings, :relevant, :boolean, null: false, default: false
  end
end
