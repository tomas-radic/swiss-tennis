class AddConsentGivenToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :consent_given, :boolean, null: false, default: false
  end
end
