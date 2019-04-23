class AddDummyToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :dummy, :boolean, null: false, default: false
  end
end
