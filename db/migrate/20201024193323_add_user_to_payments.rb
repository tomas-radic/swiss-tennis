class AddUserToPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :user, type: :uuid, foreign_key: true
  end
end
