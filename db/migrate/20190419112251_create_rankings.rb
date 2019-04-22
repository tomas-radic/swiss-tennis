class CreateRankings < ActiveRecord::Migration[5.2]
  def change
    create_table :rankings, id: :uuid do |t|
      t.references :player, type: :uuid, foreign_key: true,  null: false
      t.references :round, type: :uuid, foreign_key: true,   null: false
      t.integer :points,            null: false
      t.integer :handicap,          null: false
      t.integer :games_difference,  null: false

      t.timestamps
    end

    add_index :rankings, [:player_id, :round_id], unique: true
  end
end
