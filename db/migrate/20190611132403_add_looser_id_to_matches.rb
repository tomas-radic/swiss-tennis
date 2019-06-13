class AddLooserIdToMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :looser_id, :uuid, foreign_key: true
  end
end
