class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles, id: :uuid do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.date :last_date_interesting
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :season, type: :uuid, null: false, foreign_key: true
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
