class CreateSeasons < ActiveRecord::Migration[5.2]
  def change
    create_table :seasons, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
