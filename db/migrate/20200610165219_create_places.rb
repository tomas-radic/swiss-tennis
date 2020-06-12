class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places, id: :uuid do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 1

      t.timestamps
    end
  end
end
