class CreateHttpRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :http_requests, id: :uuid do |t|
      t.string :path, null: false
      t.integer :year, null: false
      t.integer :week, null: false
      t.string :ip_address, null: false
      t.integer :count, null: false, default: 0

      t.timestamps
    end

    add_index :http_requests, [:path, :year, :week, :ip_address], unique: true
  end
end
