class AddSpecificPurposeToRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :rounds, :specific_purpose, :boolean, null: false, default: false
  end
end
