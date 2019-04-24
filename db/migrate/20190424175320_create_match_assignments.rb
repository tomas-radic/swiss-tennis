class CreateMatchAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :match_assignments, id: :uuid do |t|
      t.references :player, type: :uuid, foreign_key: true
      t.references :match, type: :uuid, foreign_key: true

      t.timestamps
    end

    add_index :match_assignments, [:player_id, :match_id], unique: true
  end
end
