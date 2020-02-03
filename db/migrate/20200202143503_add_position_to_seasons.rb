class AddPositionToSeasons < ActiveRecord::Migration[5.2]
  def change
    add_column :seasons, :position, :integer, null: false, default: 1
  end
end
