class AddDefaultValueToMatchesNotes < ActiveRecord::Migration[5.2]
  def change
    Match.where(note: nil).update_all(note: '')
    change_column :matches, :note, :string, null: false, default: ''
  end
end
