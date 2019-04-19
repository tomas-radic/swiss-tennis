class CreateScores < ActiveRecord::Migration[5.2]
  def change
    create_table :scores, id: :uuid do |t|
      t.references :player, type: :uuid, foreign_key: true,  null: false
      t.references :round, type: :uuid, foreign_key: true,   null: false
      t.integer :points,            null: false
      t.integer :handicap,          null: false
      t.integer :games_difference,  null: false

      t.timestamps
    end
  end
end
