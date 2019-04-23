class CreateEnrollments < ActiveRecord::Migration[5.2]
  def change
    create_table :enrollments, id: :uuid do |t|
      t.references :season, type: :uuid, foreign_key: true, null: false
      t.references :player, type: :uuid, foreign_key: true, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :enrollments, [:season_id, :player_id], unique: true
  end
end
