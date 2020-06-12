class AddPlayInfoToMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :play_time, :integer
    add_reference :matches, :place, type: :uuid, foreign_key: true
  end
end
