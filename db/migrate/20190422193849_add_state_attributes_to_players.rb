class AddStateAttributesToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :active, :boolean, null: false, default: true
    add_column :players, :dummy, :boolean, null: false, default: false
  end
end
