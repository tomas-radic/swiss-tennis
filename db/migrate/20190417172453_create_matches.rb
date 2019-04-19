class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches, id: :uuid do |t|
      t.references :player1, type: :uuid, foreign_key: { to_table: :players },    null: false
      t.references :player2, type: :uuid, foreign_key: { to_table: :players },    null: false
      t.references :winner, type: :uuid, foreign_key: { to_table: :players }
      t.references :round, type: :uuid, foreign_key: true,                        null: false
      t.string :type,         null: false
      t.boolean :published,   null: false, default: false
      t.boolean :finished,    null: false, default: false
      t.string :note
      t.integer :set1_player1_score
      t.integer :set1_player2_score
      t.integer :set2_player1_score
      t.integer :set2_player2_score
      t.integer :set3_player1_score
      t.integer :set3_player2_score

      t.timestamps
    end
  end
end
