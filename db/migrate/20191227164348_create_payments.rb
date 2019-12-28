class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments, id: :uuid do |t|
      t.integer :amount,        null: false
      t.string :text_amount,    null: false
      t.date :paid_on,          null: false
      t.string :description

      t.timestamps
    end
  end
end
