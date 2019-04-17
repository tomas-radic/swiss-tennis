class CreateRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :rounds, id: :uuid do |t|
      t.references :season, type: :uuid, foreign_key: true
      t.integer :position
      t.string :label
      t.date :period_begins
      t.date :period_ends
      t.boolean :closed

      t.timestamps
    end
  end
end
