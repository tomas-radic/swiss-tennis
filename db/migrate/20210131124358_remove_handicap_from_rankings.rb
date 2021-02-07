class RemoveHandicapFromRankings < ActiveRecord::Migration[5.2]
  def change
    remove_column :rankings, :handicap, :integer
  end
end
