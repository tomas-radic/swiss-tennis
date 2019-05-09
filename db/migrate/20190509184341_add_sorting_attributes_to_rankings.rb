class AddSortingAttributesToRankings < ActiveRecord::Migration[5.2]
  def change
    add_column :rankings, :sets_difference, :integer, null: false, default: 0
    add_column :rankings, :relevant, :boolean, null: false, default: false
  end
end
