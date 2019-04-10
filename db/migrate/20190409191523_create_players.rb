class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name,  null: false
      t.string :phone
      t.string :email
      t.integer :birth_year
      t.references :category, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
