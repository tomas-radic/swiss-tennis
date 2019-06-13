class AddRetiredPlayerToMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :retired_player_id, :uuid, foreign_key: true
  end
end
